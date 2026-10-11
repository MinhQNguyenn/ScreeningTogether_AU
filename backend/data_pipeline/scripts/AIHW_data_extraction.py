"""
The data adapted from AIHW belongs to the National Cervical Screening Program monitoring report 2025.
However, the data tables provided contain multiple subsets and different layouts, which require careful extraction.

Each sheet in the provided dataset usually contains:
- Table headings (usually clearly state the period and main indicators/features of the table)
- Logo rows (around 2-3 first rows)
- 2-3 side-by-side sub-tables
- Multi-row headers
- Some contain number, per cent and population section
- Summary rows ("Ages 25-74 years", "All ages", "Crude rate", "AS rate", etc.)
- Footnotes below the table

In general, there are slight differences in layouts between sheets and tables; 
Most header rows and data ranges are now auto-detected rather than manually
specified, but auto-detection has its own edge cases (partial-year data,
inconsistent footnote formats, blocks with missing codes), several of which
were only found by running this against real files. Don't assume a new
table extracts correctly without checking its actual output.
"""
#testing data files
#wb = openpyxl.load_workbook('backend/data_pipeline/data/AIHW_CAN166_recruitment_data_tables.xlsx', data_only=True)
#ws = wb['Table S1.2'] 
#print("Native Excel tables found:", dict(ws.tables.items())) #which resulted in {}

#set up
import openpyxl
import re
import pandas as pd


#empty dictionary to store the opened workbook
_WORKBOOK_CACHE = {}

def _load_workbook_cached(filepath: str):
    """
    as functions below has to re-read and re-parse the entire Excel file from disk every single time
    this function has been written to make sure a given Excel file only ever gets loaded from disk once
    """
    if filepath not in _WORKBOOK_CACHE:
        _WORKBOOK_CACHE[filepath] = openpyxl.load_workbook(filepath, data_only=True)
    return _WORKBOOK_CACHE[filepath]

#(S\d+\.\d+[a-z]?): table code, (.+?): description, , (\d{4}) : year start, [–-]: en dash/plain hyphen, (\d{4}): year end
#regrex for title of sub data table using year range (2018-2022)
TITLE_PATTERN_YEAR_RANGE=re.compile(r"Table (S\d+\.\d+[a-z]?): (.+?), (\d{4})[–-](\d{4})")
#regrex for title of sub data table using year list (2018,2019,2020)
TITLE_PATTERN_YEAR_LIST=re.compile(r"Table (S\d+\.\d+[a-z]?): (.+?)((?:, \d{4})+(?:, and \d{4})?)$")
#regrex for title of sub data table using year range (2018 to 2022)
TITLE_PATTERN_YEAR_TO = re.compile(r"Table (S\d+\.\d+[a-z]?): (.+?), (\d{4}) to (\d{4})")


def find_table_title_AIHW(filepath:str, sheet_name: str, label_col: str) -> dict: 
    """
    This function is used for detecting the title cell of the table/sub-table and
    parses out the table number, description, and reporting year/range. 

    For example: Table S1.2a: Participation, by age, state and territory, 2018–2022	

    Without this, the critical part of the data table coverage will be missing.									
    """
    wb= _load_workbook_cached(filepath)
    ws= wb[sheet_name]
    column_index= openpyxl.utils.column_index_from_string(label_col) #turn 'B' into 2, etc

    for row in range(1,ws.max_row+1): #scan the whole column looking for a title
        content = ws.cell(row=row, column=column_index).value
        if not content:
            continue
        content=str(content)

        align_range= TITLE_PATTERN_YEAR_RANGE.search(str(content))
        if align_range:
            return{"table_number": align_range.group(1),
                   "description": align_range.group(2),
                   "year_start": int(align_range.group(3)),
                   "year_end": int(align_range.group(4)),
                   "title_row": row-1} #since pandas skiprows parameter counts rows starting at 0

        align_list= TITLE_PATTERN_YEAR_LIST.search(str(content))
        if align_list:
            years = [int(y) for y in re.findall(r"\d{4}", align_list.group(3))]
            return{"table_number": align_list.group(1),
                   "description": align_list.group(2).rstrip(", "),
                   "year_start": min(years),
                   "year_end": max(years),
                    "title_row": row-1}

        align_to = TITLE_PATTERN_YEAR_TO.search(content)
        if align_to:
            return {"table_number": align_to.group(1), 
                    "description": align_to.group(2),
                    "year_start": int(align_to.group(3)), 
                    "year_end": int(align_to.group(4)),
                    "title_row": row - 1}

    #bug detection
    raise ValueError(
        f"Could not find a table title matching the defined pattern in"
        f" column {label_col} on sheet '{sheet_name}'- check if the column"
        f" letter is correct or the title format has changed.")
            

def find_table_header_AIHW(filepath: str, sheet_name: str, label_col: str, below_row: int, label_text: str) -> dict:
    """
    Identify the header row using known main label, which is 'Age Group' (skimming through the raw dataset),
    starting from the below_row below the title, ensure the correct scope within that specific 
    sub-table instead of the other on the same sheet.

    Additionally this also avoids hardcoding a fixed row from the title as there are multiple layouts.
    """
    wb= _load_workbook_cached(filepath)
    ws= wb[sheet_name]
    column_index= openpyxl.utils.column_index_from_string(label_col)

    for row in range(below_row+1, ws.max_row+1):  #start searching just below the title
        cell_value = ws.cell(row=row, column=column_index).value
        if cell_value is not None and str(cell_value).strip() == label_text.strip():
            return row-1

    #bug detection
    raise ValueError(f"Could not find the header label '{label_text}' in column {label_col} below row {below_row} on sheet {sheet_name}.")

def extract_table_AIHW(filepath: str, sheet_name: str, table_col: str, 
                       shared_title_label_col: str, data_end_row: int, label_text: str = "Age group" ) -> pd.DataFrame:
    """
    Extracts the sub-table block from the sheet into cleaned dataframe, with the table's title information 
    (code, desc, year range) attached to the result via df.attrs; therefore, downstream code knows what data
    represents.
    """
    metadata = find_table_title_AIHW(filepath, sheet_name, shared_title_label_col)
    header_row = find_table_header_AIHW(filepath, sheet_name, shared_title_label_col, below_row=metadata['title_row'],label_text=label_text)

    raw=pd.read_excel(filepath, sheet_name=sheet_name, usecols=table_col, skiprows=header_row, header=0, nrows=(data_end_row-header_row))

    raw=raw.dropna(how='all').reset_index(drop=True)
    raw.attrs.update(metadata)

    return raw

def split_section_AIHW(df: pd.DataFrame, section_labels: list = None) -> dict:
    """
    Split the sub-table into how many sections it has.

    For example: S1.2a has 'Number', 'Per cent', 'Population'. However, not all sub-table
    has the same sections or number of sections. Therefore, this function is to detect all section titles 
    that actually present and splits on them. 																																    																																					
    """
    section_labels = section_labels or ["Number", "Per cent", "Population", "Per 1,000 participants screened",
                                        "Number participants screened", "Number of new cases", "Number of new cases per 100,000 women",
                                        "Number of deaths", "Number of deaths per 100.000 women"]
    markers = [] #where each section starts in the dataframe
    for label in section_labels:
        mask = df.apply(lambda row: row.astype(str).str.strip().eq(label).any(), axis=1)
        idx = df[mask].index
        if len(idx) > 0:
            markers.append((idx[0], label)) 

    if not markers:
        raise ValueError(
            f"Couldn't find any of {section_labels} anywhere in the extracted rows. "
            f"Check the row range covers the section markers, or pass the correct section_labels for this table.")
 
    markers.sort(key=lambda m: m[0])  # ensure sections are split in the order they appear on the sheet
 
    sections = {}
    for i, (start_idx, label) in enumerate(markers):
        end_idx = markers[i + 1][0] if i + 1 < len(markers) else len(df)  #next marker, or end of dataframe if this is the last section
        section_df = df.iloc[start_idx + 1 : end_idx].dropna(axis=1, how="all").reset_index(drop=True)
        sections[label.lower().replace(" ", "_")] = section_df
 
    return sections

def clean_numeric_columns_AIHW(df: pd.DataFrame, exclude: list=None) -> pd.DataFrame:
    """
    Covert the numeric data into proper numeric types to ensure the consistency.
    Exclude the label column (like Age group)
    """
    exclude = exclude or []
    for col in df.columns:
        if col in exclude:
            continue
        df[col] = (df[col]
                   .astype(str)
                   .str.replace(",", "", regex=False)
                   .replace("nan", pd.NA))
        df[col] = pd.to_numeric(df[col], errors="coerce") #anything that's still not a number (like a leftover marker) just becomes NaN here
    return df

def extract_long_table_AIHW(filepath: str, sheet_name: str, table_col: str,
                            col_name_code: str, col_name: str, label_text: str=None) -> pd.DataFrame: #for SA2, SA3, PHN
    """
    Extract AIHW long format tables of small areas (SA2, SA3, PHN), which slightly different
    from the other tables. 

    1. The area code/name only appears on the FIRST row of each area's block
       (one block per age group, ~10 rows) — every row after that is blank
       in those columns until the next area starts. Left as-is, every row
       after the first per area loses its area identifier entirely.
 
    2. Small areas have counts suppressed as the string 'n.p.' (not
       published) for privacy — roughly a quarter of values in this dataset.
       These must become proper NaN, not be silently coerced to 0 (which
       would understate true participation) or crash a numeric conversion.
    """

    label_text= label_text or col_name_code
    metadata= find_table_title_AIHW(filepath, sheet_name, label_col=table_col.split(":")[0])

    header_row = find_table_header_AIHW(filepath, sheet_name,
                                        label_col= table_col.split(":")[0],
                                        below_row=metadata["title_row"],
                                        label_text=label_text)
    raw = pd.read_excel(filepath, sheet_name=sheet_name, usecols=table_col,
                     skiprows=header_row, header=0)
    raw = raw.dropna(how="all").reset_index(drop=True)

    #footnote/source lines at the bottom of the sheet land in the same column as the
    #area code, so they need filtering out before anything else, or they'd be read
    #as if they were extra area rows
    is_footnote = raw[col_name_code].apply(
        lambda v: bool(FOOTNOTE_SIGNATURE.match(str(v).strip()))
    )
    raw = raw[~is_footnote].reset_index(drop=True)

    #a new area's block starts wherever col_name (the area name) has a real value.
    #group by that first, THEN forward-fill within each group — this stops a block
    #with a genuinely blank code (like the national "Australia" total row) from
    #picking up the previous area's code by mistake
    block_id = raw[col_name].notna().cumsum()
    raw[col_name] = raw.groupby(block_id)[col_name].transform(lambda s: s.ffill())
    raw[col_name_code] = raw.groupby(block_id)[col_name_code].transform(lambda s: s.ffill())

    # Rows with no real area code left (the national total block) aren't
    # actual small-area data -> drop them. A national total is already
    # available from the state-level table's own "Australia" column.
    raw = raw[raw[col_name_code].notna()].reset_index(drop=True)

    #convert the 'n.p.' suppression marker to a real NaN, and flag. It in a separate column so downstream analysis can distinguish
    #"genuinely zero" from "suppressed for privacy" —> collapsing these two cases would misrepresent small-area participation as lower than it is.
    numeric_cols = [c for c in raw.columns if c not in (col_name_code,col_name, "Age group")]
    for col in numeric_cols:
        raw[f"{col}_suppressed"] = raw[col].astype(str).str.strip() == "n.p."
        raw[col] = pd.to_numeric(raw[col], errors="coerce")
 
    raw.attrs.update(metadata)
    return raw


def extract_two_level_header_AIHW(filepath: str, sheet_name: str, table_col: str, label_col: str,
                                  top_header_row: int, sub_header_row: int, data_end_row: int) -> pd.DataFrame:
    """
    Handles AIHW tables with a genuine TWO-LEVEL header — e.g. S2.2, where a
    year (2019, 2020, 2021...) spans several sub-columns (Invited, Responded,
    Crude rate), but the year label only appears ONCE per block (a merged
    cell), not repeated above every sub-column.
 
    This is structurally different from S1.2/S1.4's single-row header, and
    reading it with a single header row would silently lose which year each
    "Invited"/"Responded" column belongs to. This function forward-fills the
    top-level (year) labels across their block, then combines both levels
    into one unambiguous column name like "2019_Invited".
    """
    wb = _load_workbook_cached(filepath)
    ws = wb[sheet_name]
 
    col_letters = table_col.split(":")
    start_col = openpyxl.utils.column_index_from_string(col_letters[0])
    end_col = openpyxl.utils.column_index_from_string(col_letters[1])
 
    # Read both header rows directly, forward-filling the top (year) row
    # across its merged block since openpyxl only returns the value in the
    # top-left cell of a merged range — every other cell in that block is None.
    top_labels, sub_labels = [], []
    last_top = None
    for col in range(start_col, end_col + 1):
        top_val = ws.cell(row=top_header_row, column=col).value
        if top_val is not None:
            last_top = top_val
        top_labels.append(last_top)
        sub_labels.append(ws.cell(row=sub_header_row, column=col).value)
 
    combined_headers = [f"{t}_{s}" if t is not None else s for t, s in zip(top_labels, sub_labels)]
 
    # Spacer columns between year-blocks have no sub-header at all — these
    # aren't real data, they're blank visual gaps in the report layout, so
    # drop them rather than keeping them as garbage "2019_None" columns.
    keep_mask = [s is not None for s in sub_labels]
 
    raw = pd.read_excel(
        filepath,
        sheet_name=sheet_name,
        usecols=table_col,
        skiprows=sub_header_row,
        header=None,
        nrows=(data_end_row - sub_header_row))
    
    raw = raw.loc[:, keep_mask]
    raw.columns = [h for h, keep in zip(combined_headers, keep_mask) if keep]

    #the label column can also have footnote/legend text mixed in below the real
    #rows (e.g. a note about small counts, or a paragraph explaining what the
    #letter-type codes mean) - filter it out the same way as the long-table function
    label_col_name = raw.columns[0]
    is_footnote = raw[label_col_name].apply(lambda v: bool(FOOTNOTE_SIGNATURE.match(str(v).strip())))
    raw = raw[~is_footnote].reset_index(drop=True)
    raw = raw.dropna(how="all").reset_index(drop=True)
 
    metadata = find_table_title_AIHW(filepath, sheet_name, label_col=label_col)
    raw.attrs.update(metadata)
    return raw

#regrex for footnote/source lines that shouldn't be read as real data rows
FOOTNOTE_SIGNATURE = re.compile(r"^(Notes|Note:|Source:|\d+\.\s|n\.p\.\s+not\s+published|From \d{4}:)")

def find_table_data_end_AIHW(filepath: str, sheet_name: str, table_col: str, label_col: str, start_row: int) -> int:
    """
    Works out the last real row of data in a sub-table, instead of a
    manually-counted row number. Stops at the first footnote/source line
    it finds, but skips over ordinary blank spacer rows along the way
    rather than treating them as the end.
    """
    wb =_load_workbook_cached(filepath)
    ws = wb[sheet_name]
    col_idx = openpyxl.utils.column_index_from_string(label_col)

    last_real_data_row = start_row
    for row in range(start_row + 2, ws.max_row + 1): #+2 to skip past the header row itself
        label_value = ws.cell(row=row, column=col_idx).value

        if label_value is not None and FOOTNOTE_SIGNATURE.match(str(label_value).strip()):
            break  # genuine footnote/source line, table has ended

        row_has_any_content = any(
            ws.cell(row=row, column=c).value is not None
            for c in range(
                openpyxl.utils.column_index_from_string(table_col.split(":")[0]),
                openpyxl.utils.column_index_from_string(table_col.split(":")[1]) + 1,
            )
        )
        if not row_has_any_content:
            continue #a blank spacer row, not the end of the table - keep going

        last_real_data_row = row

    return last_real_data_row - 1  # matches the 0-indexed convention used elsewhere in this file

def find_all_table_blocks_AIHW(filepath: str, sheet_name: str, header_row: int, title_scan_rows: int = 5) -> list:
    """
    Finds every sub-table title on a sheet and works out each one's real column
    range by checking the header row for where the content actually stops -
    rather than assuming every block is the same width (some sheets have a
    partial/incomplete last block, e.g. a partial year that only has 6 months
    instead of 12).
 
    Returns a list of dicts: [{"start_col": "B", "end_col": "P"}, ...]
    """
    wb = _load_workbook_cached(filepath)
    ws = wb[sheet_name]
 
    title_scan_pattern = re.compile(r"Table (S\d+\.\d+[a-z]?):")
    title_cols = []
    for row in ws.iter_rows(min_row=1, max_row=title_scan_rows):
        for cell in row:
            if cell.value and title_scan_pattern.search(str(cell.value)):
                title_cols.append(cell.column)
    title_cols = sorted(set(title_cols))
 
    blocks = []
    for i, start_col in enumerate(title_cols):
        next_title_col = title_cols[i + 1] if i + 1 < len(title_cols) else ws.max_column + 2
        end_col = start_col
        for col in range(start_col, next_title_col - 1): #walk right until the header row goes blank
            if ws.cell(row=header_row, column=col).value is not None:
                end_col = col
        blocks.append({
            "start_col": openpyxl.utils.get_column_letter(start_col),
            "end_col": openpyxl.utils.get_column_letter(end_col),
        })
    return blocks

def extract_and_save_wide_table(filepath, sheet_name, table_col, label_col, extracted_dir, out_prefix, label_text="Age group"):
    """Convenience wrapper: extract a wide table, split its sections, clean, and save each section to CSV."""
    meta = find_table_title_AIHW(filepath, sheet_name, label_col)
    hdr = find_table_header_AIHW(filepath, sheet_name, label_col, below_row=meta["title_row"], label_text=label_text)
    end = find_table_data_end_AIHW(filepath, sheet_name, table_col, label_col=label_col, start_row=hdr)
    df = extract_table_AIHW(filepath, sheet_name, table_col, label_col, data_end_row=end, label_text=label_text)
    df.columns = [str(c).split(".")[0] for c in df.columns]  #pandas adds .1/.2 etc when the same header repeats across sub-tables -> strip that back off
    df.columns.values[0] = label_text
    print(f"{meta['table_number']} ({meta['year_start']}-{meta['year_end']}): shape={df.shape}")
    try:
        sections = split_section_AIHW(df)
        for name, section_df in sections.items():
            cleaned = clean_numeric_columns_AIHW(section_df, exclude=[section_df.columns[0]])
            out_path = extracted_dir / f"{out_prefix}_{name}.csv"
            cleaned.to_csv(out_path, index=False)
            print(f"  saved {name}: {len(cleaned)} rows -> {out_path.name}")
    except ValueError:
        # some tables (e.g. S1.1, S19.1, S20.1) may not have clean section markers
        # in the extracted range —> save as a single file instead of failing
        cleaned = clean_numeric_columns_AIHW(df, exclude=[df.columns[0]])
        out_path = extracted_dir / f"{out_prefix}.csv"
        cleaned.to_csv(out_path, index=False)
        print(f"  saved (no sections found): {len(cleaned)} rows -> {out_path.name}")
 

if __name__ == "__main__":
    from pathlib import Path
    #build all paths relative to this script's own location, so it works no matter
    #which folder you happen to run it from
    script_dir = Path(__file__).resolve().parent
    data_dir = script_dir.parent / "data"
    extracted_dir = data_dir / "extracted"
    extracted_dir.mkdir(parents=True, exist_ok=True)
 
    RECRUITMENT_FILE = str(data_dir / "AIHW_CAN166_recruitment_data_tables.xlsx")
    OUTCOMES_FILE = str(data_dir / "AIHW_CAN166_outcomes_data_tables.xlsx")
  
    #S1.1: participation trend, no state/area breakdown ---
    extract_and_save_wide_table(RECRUITMENT_FILE, "Table S1.1", "B:F", "B", extracted_dir, "s1_1_participation_trend")
 
    # S1.2: participation by state/territory — ALL sub-tables, auto-detected
    # (Previously hardcoded B:L / N:X / Z:AJ by hand — unnecessary, since
    # find_all_table_blocks_AIHW already exists and correctly detects these
    # same ranges automatically, confirmed by testing it directly.)
    hdr_row_12 = find_table_header_AIHW(
        RECRUITMENT_FILE, "Table S1.2", "B",
        below_row=find_table_title_AIHW(RECRUITMENT_FILE, "Table S1.2", "B")["title_row"],
        label_text="Age group",
    )
    for b in find_all_table_blocks_AIHW(RECRUITMENT_FILE, "Table S1.2", header_row=hdr_row_12 + 1):
        table_col = f"{b['start_col']}:{b['end_col']}"
        meta = find_table_title_AIHW(RECRUITMENT_FILE, "Table S1.2", b["start_col"])
        extract_and_save_wide_table(
            RECRUITMENT_FILE, "Table S1.2", table_col, b["start_col"],
            extracted_dir, f"s1_2{meta['table_number'][-1]}_participation_state")
 
    #S1.4: participation by socioeconomic area — ALL sub-tables, auto-detected
    hdr_row_14 = find_table_header_AIHW(
        RECRUITMENT_FILE, "Table S1.4", "B",
        below_row=find_table_title_AIHW(RECRUITMENT_FILE, "Table S1.4", "B")["title_row"],
        label_text="Age group",
    )
    for b in find_all_table_blocks_AIHW(RECRUITMENT_FILE, "Table S1.4", header_row=hdr_row_14 + 1):
        table_col = f"{b['start_col']}:{b['end_col']}"
        meta = find_table_title_AIHW(RECRUITMENT_FILE, "Table S1.4", b["start_col"])
        extract_and_save_wide_table(
            RECRUITMENT_FILE, "Table S1.4", table_col, b["start_col"],
            extracted_dir, f"s1_4{meta['table_number'][-1]}_participation_socioeconomic")
 
    #S1.5: number of HPV tests by month, ALL year-blocks (2018-2025)
    print("\n--- S1.5: HPV tests by month (all year blocks) ---")
    hdr_row_for_blocks = find_table_header_AIHW(
        RECRUITMENT_FILE, "Table S1.5", "B",
        below_row=find_table_title_AIHW(RECRUITMENT_FILE, "Table S1.5", "B")["title_row"],
        label_text="Age group",
    )
    s1_5_blocks = find_all_table_blocks_AIHW(RECRUITMENT_FILE, "Table S1.5", header_row=hdr_row_for_blocks + 1)
    for b in s1_5_blocks:
        table_col = f"{b['start_col']}:{b['end_col']}"
        meta = find_table_title_AIHW(RECRUITMENT_FILE, "Table S1.5", b["start_col"])
        extract_and_save_wide_table(
            RECRUITMENT_FILE, "Table S1.5", table_col, b["start_col"],
            extracted_dir, f"s1_5_{meta['table_number'].lower()}_hpv_tests_by_month")
 
    #S1.6: number of self-collected HPV tests by month, ALL year-blocks
    print("\n--- S1.6: self-collected HPV tests by month (all year blocks) ---")
    hdr_row_for_blocks_16 = find_table_header_AIHW(
        RECRUITMENT_FILE, "Table S1.6", "B",
        below_row=find_table_title_AIHW(RECRUITMENT_FILE, "Table S1.6", "B")["title_row"],
        label_text="Age group",
    )
    s1_6_blocks = find_all_table_blocks_AIHW(RECRUITMENT_FILE, "Table S1.6", header_row=hdr_row_for_blocks_16 + 1)
    for b in s1_6_blocks:
        table_col = f"{b['start_col']}:{b['end_col']}"
        meta = find_table_title_AIHW(RECRUITMENT_FILE, "Table S1.6", b["start_col"])
        extract_and_save_wide_table(
            RECRUITMENT_FILE, "Table S1.6", table_col, b["start_col"],
            extracted_dir, f"s1_6_{meta['table_number'].lower()}_self_collected_by_month")
 
    #S1.8: participation by SA3 — ALL THREE year windows
    print("\n--- S1.8: participation by SA3 (all 3 windows) ---")
    for suffix, cols, year_start, year_end in [("a", "B:G", 2018, 2022), ("b", "B:D,I:K", 2019, 2023), ("c", "B:D,M:O", 2020, 2024)]:
        s1_8 = extract_long_table_AIHW(RECRUITMENT_FILE, "Table S1.8", cols, col_name_code="SA3 Code", col_name="SA3 Name")
        s1_8.columns = ["SA3 Code", "SA3 Name", "Age group", "Participated", "Population", "Participation (%)",
                        "Participated_suppressed", "Population_suppressed", "Participation (%)_suppressed"]
        print(f"S1.8 {year_start}-{year_end}: {len(s1_8)} rows, {s1_8['SA3 Code'].nunique()} unique SA3 areas")
        s1_8.to_csv(extracted_dir / f"s1_8_participation_sa3_{year_start}_{year_end}.csv", index=False)
 
    #S2.1: response to invitation by age
    print("\n--- S2.1: response to invitation, by age ---")
    s2_1 = extract_two_level_header_AIHW(RECRUITMENT_FILE, "Table S2.1", "B:AF", "B", top_header_row=4, sub_header_row=5, data_end_row=17)
    print(f"S2.1: columns={list(s2_1.columns)}")
    s2_1.to_csv(extracted_dir / "s2_1_response_to_invitation_by_age.csv", index=False)
 
    #S2.2: response to invitation by state/territory
    print("\n--- S2.2: response to invitation, by state ---")
    s2_2 = extract_two_level_header_AIHW(RECRUITMENT_FILE, "Table S2.2", "B:AF", "B", top_header_row=4, sub_header_row=5, data_end_row=14)
    print(f"S2.2: columns={list(s2_2.columns)}")
    s2_2.to_csv(extracted_dir / "s2_2_response_to_invitation_by_state.csv", index=False)
 
    #S2.3: response to invitation by letter type
    print("\n--- S2.3: response to invitation, by letter type ---")
    s2_3 = extract_two_level_header_AIHW(RECRUITMENT_FILE, "Table S2.3", "B:AF", "B", top_header_row=4, sub_header_row=5, data_end_row=13)
    print(f"S2.3: columns={list(s2_3.columns)}")
    s2_3.to_csv(extracted_dir / "s2_3_response_to_invitation_by_letter_type.csv", index=False)
 
    #OUTCOMES FILE (S19/S20)
    print("\n--- S19/S20: cervical cancer incidence & mortality---")
    outcomes_tables = [
        ("Table S19.1", "B:AP", "Age group"),
        ("Table S19.5", "B:K", "Age group"),
        ("Table S19.7", "B:H", "Age group"),
        ("Table S20.1", "B:AR", "Age group"),
        ("Table S20.3", "B:K", "Age group"),
        ("Table S20.5", "B:H", "Age group"),
    ]
    for sheet_name, table_col, label_text in outcomes_tables:
        out_prefix = sheet_name.replace("Table ", "").replace(".", "_").lower() + "_incidence_mortality"
        extract_and_save_wide_table(OUTCOMES_FILE, sheet_name, table_col, "B", extracted_dir, out_prefix, label_text=label_text)
 
    print(f"\nAll extracted tables saved to: {extracted_dir}")
    