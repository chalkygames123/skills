import { defineConfig } from 'oxfmt';

export default defineConfig({
	ignorePatterns: ['skills/react-aria/'],
	singleQuote: true,
	sortImports: {},
	sortPackageJson: {
		sortScripts: true,
	},
});
