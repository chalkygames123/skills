import { defineConfig } from 'oxfmt';

export default defineConfig({
	ignorePatterns: ['skills/third-party/'],
	singleQuote: true,
	sortImports: {},
	sortPackageJson: {
		sortScripts: true,
	},
});
