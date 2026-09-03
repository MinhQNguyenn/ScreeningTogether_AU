# ScreeningTogether AU — UI Branch

## 1. Branch Overview

The **UI** branch contains the frontend implementation of ScreeningTogether AU.

This branch is responsible for building the user interface and user-facing interactions of the application, including:

* Landing page and cervical cancer screening information
* Dynamic cervical screening statistics
* Frequently Asked Questions (FAQ)
* GP finder interface
* Educational game interfaces
* GP Runner game
* Temporary placeholder pages
* Frontend routing and navigation
* Frontend development, testing, linting, and type checking

The frontend is built using **Vue 3, TypeScript, and Vite**.

---

## 2. Frontend Folder Structure

The main frontend structure is organised as follows:

```text
frontend/
├── public/
├── src/
│   ├── assets/
│   │   └── ...
│   │
│   ├── components/
│   │   └── ...
│   │
│   ├── views/
│   │   ├── HomeView.vue
│   │   ├── GameView.vue
│   │   ├── GPFinderView.vue
│   │   ├── GpRunnerGameView.vue
│   │   └── Placeholder.vue
│   │
│   ├── router/
│   │   └── ...
│   │
│   ├── App.vue
│   └── main.ts
│
├── package.json
├── vite.config.ts
├── tsconfig.json
├── eslint.config.ts
└── ...
```

### Main Views

| View                   | Purpose                                                                                                                        |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `HomeView.vue`         | Landing page containing information about cervical cancer, dynamic statistics, and FAQs about cervical cancer.                 |
| `GameView.vue`         | Gaming page that provides access to the project's educational games.                                                           |
| `GPFinderView.vue`     | GP finder page where users can find a GP near them for cervical cancer screening.                                              |
| `GpRunnerGameView.vue` | First educational game, **GP Runner**, where the player controls a character moving through hurdles and stigmas to reach a GP. |
| `Placeholder.vue`      | Temporary "Coming Soon" page used for features that are not yet implemented.                                                   |

---

## 3. Dependencies

The UI branch uses Vue 3 with TypeScript and Vite.

### Core Frontend

| Dependency           |  Version | Purpose                                    |
| -------------------- | -------: | ------------------------------------------ |
| `vue`                | `3.5.18` | Frontend framework                         |
| `vue-router`         |  `4.6.4` | Client-side page routing                   |
| `typescript`         |  `5.8.3` | Type-safe JavaScript development           |
| `vite`               |  `7.0.6` | Frontend development server and build tool |
| `@vitejs/plugin-vue` |  `6.0.1` | Vue support for Vite                       |
| `vue-tsc`            | `2.2.12` | Type checking for Vue + TypeScript         |

### CSS and Build Tools

| Dependency     |   Version | Purpose                           |
| -------------- | --------: | --------------------------------- |
| `tailwindcss`  |  `3.4.17` | Utility-first CSS framework       |
| `postcss`      |   `8.5.6` | CSS transformation and processing |
| `autoprefixer` | `10.4.21` | Adds vendor prefixes to CSS       |

### Testing

| Dependency              |  Version | Purpose                            |
| ----------------------- | -------: | ---------------------------------- |
| `vitest`                |  `3.2.4` | Unit and component testing         |
| `@vue/test-utils`       |  `2.4.6` | Vue component testing utilities    |
| `jsdom`                 | `26.1.0` | Browser-like environment for tests |
| `@types/jsdom`          | `21.1.7` | TypeScript types for jsdom         |
| `@vitest/eslint-plugin` |  `1.3.4` | ESLint integration for Vitest      |

### Code Quality

| Dependency                      |  Version | Purpose                         |
| ------------------------------- | -------: | ------------------------------- |
| `eslint`                        | `9.32.0` | JavaScript/TypeScript linting   |
| `eslint-plugin-vue`             | `10.2.0` | Vue-specific ESLint rules       |
| `prettier`                      |  `3.5.3` | Code formatting                 |
| `@vue/eslint-config-prettier`   | `10.2.0` | ESLint and Prettier integration |
| `@vue/eslint-config-typescript` | `14.6.0` | TypeScript ESLint configuration |

### Development Utilities

| Dependency                 |   Version | Purpose                                                 |
| -------------------------- | --------: | ------------------------------------------------------- |
| `vite-plugin-vue-devtools` |   `7.7.7` | Vue development tools integration                       |
| `npm-run-all2`             |   `8.0.4` | Running multiple npm scripts                            |
| `jiti`                     |   `2.5.1` | Runtime support for JavaScript/TypeScript configuration |
| `@types/node`              | `22.17.0` | Node.js TypeScript definitions                          |
| `@tsconfig/node22`         |  `22.0.2` | Node.js 22 TypeScript configuration                     |
| `@vue/tsconfig`            |   `0.7.0` | Recommended TypeScript configuration for Vue            |

---

## 4. Start Up

### Prerequisites

Make sure the following are installed:

* Node.js
* npm
* Git

### 1. Navigate to the frontend

From the project root:

```powershell
cd frontend
```

### 2. Install dependencies

If dependencies have not been installed yet:

```powershell
npm install
```

### 3. Start the development server

```powershell
npm run dev
```

Vite will display the local development URL in the terminal, normally similar to:

```text
http://localhost:5173/
```

Open the displayed URL in a browser.

### 4. Type Check

To check the Vue and TypeScript code:

```powershell
npm run type-check
```

### 5. Build for Production

```powershell
npm run build
```

### 6. Preview the Production Build

```powershell
npm run preview
```

---

## 5. Development Workflow

For frontend development:

1. Switch to the `UI` branch.
2. Navigate to the `frontend` directory.
3. Install dependencies if required.
4. Run the Vite development server.
5. Make changes to the Vue components, views, assets, or routing.
6. Run type checking before committing changes.
7. Build the frontend to verify that the production build succeeds.

Example:

```powershell
git checkout UI

cd frontend

npm install

npm run dev
```

Before committing:

```powershell
npm run type-check
npm run build
```
