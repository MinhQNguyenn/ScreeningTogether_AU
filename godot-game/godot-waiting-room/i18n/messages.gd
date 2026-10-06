# On-screen text only. Audio intentionally remains unchanged.
# Values: Mandarin (Simplified), Arabic, Vietnamese, Cantonese (Traditional).
extends RefCounted

const STRINGS := {
	"Language": [
		"语言",
		"اللغة",
		"Ngôn ngữ",
		"語言"
	],
	"WELCOME TO THE CLINICAL CENTER": [
		"欢迎来到诊所",
		"مرحباً بكم في المركز الطبي",
		"CHÀO MỪNG ĐẾN PHÒNG KHÁM",
		"歡迎嚟到診所"
	],
	"May I ask for your name and the purpose of your visit today?": [
		"请问您的姓名和今天就诊的原因是什么？",
		"ما اسمك وما سبب زيارتك اليوم؟",
		"Xin cho biết họ tên và lý do bạn đến khám hôm nay?",
		"請問你叫咩名，同埋今日嚟診所做咩？"
	],
	"First name": [
		"名",
		"الاسم الأول",
		"Tên",
		"名"
	],
	"Last name": [
		"姓",
		"اسم العائلة",
		"Họ",
		"姓"
	],
	"e.g. Emily": [
		"例如：Emily",
		"مثال: Emily",
		"Ví dụ: Emily",
		"例如：Emily"
	],
	"e.g. Taylor": [
		"例如：Taylor",
		"مثال: Taylor",
		"Ví dụ: Taylor",
		"例如：Taylor"
	],
	"Purpose of visit": [
		"就诊原因",
		"سبب الزيارة",
		"Lý do đến khám",
		"到診原因"
	],
	"Cervical cancer screening": [
		"宫颈癌筛查",
		"فحص عنق الرحم",
		"Sàng lọc ung thư cổ tử cung",
		"子宮頸癌篩查"
	],
	"CHECK IN & TAKE A SEAT": [
		"登记并入座",
		"سجّلي حضورك واجلسي",
		"ĐĂNG KÝ VÀ NGỒI CHỜ",
		"登記後請坐"
	],
	"Your name is used only during this game session.": [
		"您的姓名仅用于本次游戏。",
		"يُستخدم اسمك خلال جلسة اللعب هذه فقط.",
		"Tên của bạn chỉ được dùng trong lượt chơi này.",
		"你嘅姓名只會喺今次遊戲入面使用。"
	],
	"Please enter your first name.": [
		"请输入您的名。",
		"يرجى إدخال اسمك الأول.",
		"Vui lòng nhập tên của bạn.",
		"請輸入你嘅名。"
	],
	"Please enter your last name.": [
		"请输入您的姓。",
		"يرجى إدخال اسم العائلة.",
		"Vui lòng nhập họ của bạn.",
		"請輸入你嘅姓。"
	],
	"SIDE QUESTS": [
		"额外任务",
		"مهام إضافية",
		"NHIỆM VỤ PHỤ",
		"額外任務"
	],
	"%d / %d completed": [
		"已完成 %d / %d",
		"تم إنجاز %d / %d",
		"Đã hoàn thành %d / %d",
		"已完成 %d / %d"
	],
	"[ ]  Stay hydrated": [
		"[ ]  补充水分",
		"[ ]  اشربي الماء",
		"[ ]  Uống đủ nước",
		"[ ]  飲啲水"
	],
	"[DONE]  Stay hydrated   +%d": [
		"[完成]  补充水分   +%d",
		"[تم]  شرب الماء   +%d",
		"[XONG]  Uống đủ nước   +%d",
		"[完成]  飲啲水   +%d"
	],
	"[ ]  Get general support(Information)": [
		"[ ]  获取一般帮助（咨询）",
		"[ ]  اطلبي المساعدة والمعلومات",
		"[ ]  Tìm hỗ trợ (thông tin)",
		"[ ]  尋求一般協助（查詢）"
	],
	"[DONE]  Get general support   +%d": [
		"[完成]  获取一般帮助   +%d",
		"[تم]  طلب المساعدة   +%d",
		"[XONG]  Tìm hỗ trợ   +%d",
		"[完成]  尋求一般協助   +%d"
	],
	"[ ]  Screening facts found: %d / %d": [
		"[ ]  已找到筛查知识：%d / %d",
		"[ ]  معلومات الفحص المكتشفة: %d / %d",
		"[ ]  Kiến thức sàng lọc: %d / %d",
		"[ ]  已搵到篩查知識：%d / %d"
	],
	"[DONE]  Screening facts: %d / %d   +%d": [
		"[完成]  筛查知识：%d / %d   +%d",
		"[تم]  معلومات الفحص: %d / %d   +%d",
		"[XONG]  Kiến thức: %d / %d   +%d",
		"[完成]  篩查知識：%d / %d   +%d"
	],
	"Hover over objects to investigate.": [
		"将鼠标移到物品上，了解更多信息。",
		"مرّري المؤشر فوق الأشياء لاستكشافها.",
		"Di chuột lên đồ vật để khám phá.",
		"將滑鼠移到物件上面，睇吓有咩資訊。"
	],
	"Stay hydrated": [
		"补充水分",
		"شرب الماء",
		"Uống đủ nước",
		"飲啲水"
	],
	"Get general help/information": [
		"获取一般帮助或信息",
		"طلب المساعدة والمعلومات",
		"Tìm hỗ trợ hoặc thông tin",
		"尋求一般協助或資訊"
	],
	"WATER FOUNTAIN": [
		"饮水机",
		"نافورة مياه الشرب",
		"VÒI NƯỚC UỐNG",
		"飲水機"
	],
	"TAKE CARE OF YOURSELF": [
		"照顾好自己",
		"اعتني بنفسك",
		"CHĂM SÓC BẢN THÂN",
		"照顧好自己"
	],
	"GENERAL INFORMATION": [
		"一般信息",
		"معلومات عامة",
		"THÔNG TIN CHUNG",
		"一般資訊"
	],
	"ASK FOR SUPPORT": [
		"寻求帮助",
		"اطلبي المساعدة",
		"TÌM SỰ HỖ TRỢ",
		"尋求協助"
	],
	"SCREENING FACT": [
		"筛查知识",
		"معلومة عن الفحص",
		"KIẾN THỨC SÀNG LỌC",
		"篩查知識"
	],
	"DID YOU KNOW?": [
		"您知道吗？",
		"هل تعلمين؟",
		"BẠN CÓ BIẾT?",
		"你知唔知？"
	],
	"Read the information, then press Continue.": [
		"阅读信息后，点击“继续”。",
		"اقرئي المعلومات، ثم اضغطي على متابعة.",
		"Đọc thông tin, rồi nhấn Tiếp tục.",
		"睇完資訊之後，撳「繼續」。"
	],
	"Reviewed: %s": [
		"已复习：%s",
		"تمت المراجعة: %s",
		"Đã xem lại: %s",
		"已重溫：%s"
	],
	"Completed: %s": [
		"已完成：%s",
		"تم الإنجاز: %s",
		"Đã hoàn thành: %s",
		"已完成：%s"
	],
	"All side quests completed!  +%d points": [
		"所有额外任务已完成！  +%d 分",
		"أكملتِ جميع المهام الإضافية!  +%d نقطة",
		"Đã xong mọi nhiệm vụ phụ!  +%d điểm",
		"完成晒所有額外任務！  +%d 分"
	],
	"Listen for your name": [
		"请留意叫号",
		"انتبهي عند النداء على اسمك",
		"Lắng nghe tên của bạn",
		"留意幾時叫你個名"
	],
	"Respond when your name is called": [
		"叫到您的名字时，请回应",
		"استجيبي عند النداء على اسمك",
		"Phản hồi khi tên bạn được gọi",
		"叫到你個名嗰陣，請回應"
	],
	"Enter your name\nto begin": [
		"输入姓名\n开始游戏",
		"أدخلي اسمك\nللبدء",
		"Nhập tên\nđể bắt đầu",
		"輸入姓名\n開始遊戲"
	],
	"Please listen...": [
		"请留意叫号……",
		"يرجى الانتباه للنداء...",
		"Hãy lắng nghe...",
		"留意叫名……"
	],
	"Calling:\n%s": [
		"请就诊：\n%s",
		"ننادي على:\n%s",
		"Xin mời:\n%s",
		"請入診症室：\n%s"
	],
	"Wait for a name...": [
		"请等待叫号……",
		"انتظري النداء على اسم...",
		"Hãy chờ gọi tên...",
		"等叫名先……"
	],
	"Not you yet!": [
		"还没轮到您！",
		"لم يحن دورك بعد!",
		"Chưa đến lượt bạn!",
		"未輪到你呀！"
	],
	"Screening\nInformation": [
		"筛查\n信息",
		"معلومات\nالفحص",
		"Thông tin\nsàng lọc",
		"篩查\n資訊"
	],
	"Reception": [
		"接待处",
		"الاستقبال",
		"Lễ tân",
		"接待處"
	],
	"Restrooms": [
		"洗手间",
		"دورات المياه",
		"Nhà vệ sinh",
		"洗手間"
	],
	"General information desk": [
		"咨询台",
		"مكتب الاستعلامات",
		"Quầy thông tin",
		"詢問處"
	],
	"Water fountain": [
		"饮水机",
		"نافورة مياه الشرب",
		"Vòi nước uống",
		"飲水機"
	],
	"Click here when \nyou see your name": [
		"看到您的名字时\n请点击这里",
		"اضغطي هنا عندما\nترين اسمك",
		"Nhấn vào đây khi\nbạn thấy tên mình",
		"見到你個名嗰陣\n撳呢度"
	],
	"CONGRATULATIONS!": [
		"恭喜！",
		"تهانينا!",
		"CHÚC MỪNG!",
		"恭喜你！"
	],
	"Great listening, %s!\nYou recognised your name and responded in time.": [
		"%s，您听得很仔细！\n您认出了自己的名字，并及时作出了回应。",
		"أحسنتِ الاستماع يا %s!\nلقد تعرّفتِ على اسمك واستجبتِ في الوقت المناسب.",
		"Bạn lắng nghe rất tốt, %s!\nBạn đã nhận ra tên mình và phản hồi kịp thời.",
		"%s，你聽得好留心！\n你認得自己個名，仲及時回應咗。"
	],
	"Reaction score:  +%d": [
		"反应得分：  +%d",
		"نقاط الاستجابة:  +%d",
		"Điểm phản hồi:  +%d",
		"反應得分：  +%d"
	],
	"Side quest bonus:  +%d": [
		"额外任务奖励：  +%d",
		"مكافأة المهام الإضافية:  +%d",
		"Thưởng nhiệm vụ phụ:  +%d",
		"額外任務獎勵：  +%d"
	],
	"TOTAL SCORE:  %d": [
		"总分：  %d",
		"مجموع النقاط:  %d",
		"TỔNG ĐIỂM:  %d",
		"總分：  %d"
	],
	"PLAY AGAIN": [
		"再玩一次",
		"العبي مجدداً",
		"CHƠI LẠI",
		"再玩一次"
	],
	"CONTINUE JOURNEY": [
		"继续旅程",
		"تابعي الرحلة",
		"TIẾP TỤC HÀNH TRÌNH",
		"繼續旅程"
	],
	"CONTINUE  [SPACE]": [
		"继续  [空格键]",
		"متابعة  [مفتاح المسافة]",
		"TIẾP TỤC  [PHÍM CÁCH]",
		"繼續  [空白鍵]"
	],
	"Staying hydrated can make a clinic visit more comfortable. The water fountain is available for patients and visitors.": [
		"补充水分可以让就诊过程更舒适。患者和访客都可以使用饮水机。",
		"شرب الماء يمكن أن يجعل زيارتك للعيادة أكثر راحة. نافورة مياه الشرب متاحة للمريضات والمرضى والزوار.",
		"Uống đủ nước có thể giúp bạn thoải mái hơn khi đến phòng khám. Bệnh nhân và khách đến thăm đều có thể dùng vòi nước uống.",
		"飲足夠嘅水可以令你睇醫生嗰陣舒服啲。病人同訪客都可以用飲水機。"
	],
	"If you are unsure where to go, or need accessibility, language, or appointment support, ask the reception team for help.": [
		"如果您不确定该去哪里，或需要无障碍、语言或预约方面的支持，请向接待人员寻求帮助。",
		"إذا لم تعرفي أين تذهبين، أو احتجتِ إلى مساعدة في تسهيل الوصول أو اللغة أو المواعيد، فاطلبي المساعدة من فريق الاستقبال.",
		"Nếu bạn không biết đi đâu, hoặc cần hỗ trợ tiếp cận, ngôn ngữ hay lịch hẹn, hãy nhờ nhân viên lễ tân giúp đỡ.",
		"如果你唔知應該去邊，或者需要無障礙設施、語言或預約方面嘅支援，可以搵接待處幫手。"
	],
	"In Australia, more than 70% of cervical cancers occurred in women who had never screened or were overdue for screening.": [
		"在澳大利亚，超过70%的宫颈癌病例发生在从未接受筛查或已逾期未筛查的女性中。",
		"في أستراليا، حدثت أكثر من 70% من حالات سرطان عنق الرحم لدى نساء لم يسبق لهن إجراء الفحص أو تأخرن عن موعده.",
		"Tại Úc, hơn 70% các ca ung thư cổ tử cung xảy ra ở phụ nữ chưa từng sàng lọc hoặc đã quá hạn sàng lọc.",
		"喺澳洲，超過70%嘅子宮頸癌個案發生喺從未做過篩查，或者已經過咗期未做篩查嘅女性身上。"
	],
	"Cervical cancer can take 10-15 years to develop. Regular screening can detect early changes before they become cancer, giving you more time to take action.": [
		"宫颈癌可能需要10至15年才会形成。定期筛查可以在早期变化发展成癌症之前发现它们，让您有更多时间采取行动。",
		"قد يستغرق تطوّر سرطان عنق الرحم من 10 إلى 15 عاماً. يمكن للفحص المنتظم اكتشاف التغيّرات المبكرة قبل تحوّلها إلى سرطان، مما يمنحك وقتاً أطول لاتخاذ إجراء.",
		"Ung thư cổ tử cung có thể mất 10–15 năm để phát triển. Sàng lọc định kỳ có thể phát hiện thay đổi sớm trước khi trở thành ung thư, giúp bạn có thêm thời gian để hành động.",
		"子宮頸癌可能要10至15年先會形成。定期篩查可以喺早期變化變成癌症之前發現佢哋，畀你更多時間採取行動。"
	],
	"4 in 5 Australians get HPV at some point, it's common, not hereditary": [
		"每5名澳大利亚人中就有4人会在一生中某个时候感染HPV。这很常见，并不是遗传造成的。",
		"يُصاب 4 من كل 5 أستراليين بفيروس الورم الحليمي البشري في مرحلة ما من حياتهم؛ وهو شائع وليس وراثياً.",
		"Cứ 5 người Úc thì có 4 người nhiễm HPV vào một thời điểm nào đó trong đời. Đây là tình trạng phổ biến, không phải di truyền.",
		"每5個澳洲人就有4個會喺一生中某個時候感染HPV。呢個情況好常見，唔係遺傳嘅。"
	],
	"Screening-detected cancers have an 87% lower risk of death than unscreened cases.": [
		"与未接受筛查的病例相比，通过筛查发现的癌症病例的死亡风险低87%。",
		"يقل خطر الوفاة في حالات السرطان المكتشفة بالفحص بنسبة 87% مقارنة بالحالات التي لم تخضع للفحص.",
		"Các ca ung thư được phát hiện qua sàng lọc có nguy cơ tử vong thấp hơn 87% so với các ca không được sàng lọc.",
		"透過篩查發現嘅癌症個案，死亡風險比冇做篩查嘅個案低87%。"
	],
	"No face-to-face talk needed. Self-collection lets you take the swab yourself, in private.": [
		"无需面对面交谈。自我采样让您可以在私密的环境中自行用拭子采集样本。",
		"لا حاجة إلى حديث وجهاً لوجه. يتيح لك جمع العينة ذاتياً أخذ المسحة بنفسك وفي خصوصية.",
		"Không cần trao đổi trực tiếp. Tự lấy mẫu cho phép bạn dùng que lấy mẫu trong không gian riêng tư.",
		"唔使面對面傾談。自行採樣可以畀你喺私密嘅環境入面，自己用採樣棒攞樣本。"
	],
	"Going for a test doesn't mean something's already wrong. Most results come back normal.": [
		"去做检查并不代表已经出现问题。大多数检查结果都是正常的。",
		"الذهاب للفحص لا يعني وجود مشكلة بالفعل. معظم النتائج تكون طبيعية.",
		"Đi xét nghiệm không có nghĩa là bạn đã có vấn đề. Phần lớn kết quả đều bình thường.",
		"去做檢查唔代表已經有問題。大部分檢查結果都係正常嘅。"
	],
	"Your visit is confidential, protected the same as any other medical appointment.": [
		"您的就诊信息是保密的，受到与其他医疗预约相同的隐私保护。",
		"زيارتك سرية وتحظى بالحماية نفسها التي تحظى بها أي زيارة طبية أخرى.",
		"Thông tin buổi khám của bạn được giữ bí mật và bảo vệ như mọi cuộc hẹn y tế khác.",
		"你嘅到診資料會保密，同其他醫療預約一樣受到保障。"
	],
	"See screening fact 1": [
		"查看筛查知识 1",
		"قراءة معلومة الفحص 1",
		"Xem kiến thức sàng lọc 1",
		"睇篩查知識 1"
	],
	"Screening information 1": [
		"筛查信息 1",
		"معلومات الفحص 1",
		"Thông tin sàng lọc 1",
		"篩查資訊 1"
	],
	"See screening fact 2": [
		"查看筛查知识 2",
		"قراءة معلومة الفحص 2",
		"Xem kiến thức sàng lọc 2",
		"睇篩查知識 2"
	],
	"Screening information 2": [
		"筛查信息 2",
		"معلومات الفحص 2",
		"Thông tin sàng lọc 2",
		"篩查資訊 2"
	],
	"See screening fact 3": [
		"查看筛查知识 3",
		"قراءة معلومة الفحص 3",
		"Xem kiến thức sàng lọc 3",
		"睇篩查知識 3"
	],
	"Screening information 3": [
		"筛查信息 3",
		"معلومات الفحص 3",
		"Thông tin sàng lọc 3",
		"篩查資訊 3"
	],
	"See screening fact 4": [
		"查看筛查知识 4",
		"قراءة معلومة الفحص 4",
		"Xem kiến thức sàng lọc 4",
		"睇篩查知識 4"
	],
	"Screening information 4": [
		"筛查信息 4",
		"معلومات الفحص 4",
		"Thông tin sàng lọc 4",
		"篩查資訊 4"
	]
}
