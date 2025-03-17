# TypeScript-Go Template

This template provides a development environment for using Microsoft's TypeScript-Go implementation.

## Getting Started

1. Enter the development shell:

```bash
nix develop
```

2. Install dependencies:

```bash
npm install
```

3. Build your TypeScript code:

```bash
npm run build
```
This uses the `tsgo tsc` command provided by the TypeScript-Go package.

4. Run your compiled code:

```bash
node dist/index.js
```

## Ad-hoc TypeScript Compilation

You can compile individual TypeScript files directly:

```bash
# Compile a single file
tsgo tsc src/example.ts

# Compile with watch mode
tsgo tsc --watch
```

## Project Structure

* `src/index.ts` - Main entry point for your application
* `dist/` - Compiled JavaScript output
* `tsconfig.json` - TypeScript configuration

## Available Commands

* `tsgo` - The TypeScript-Go binary
* `tsc-go` - TypeScript compiler wrapper that uses TypeScript-Go
* `npm run build` - Compile the project using TypeScript-Go
* `npm start` - Run the compiled application

## Example Output

```
Files: 160
Types: 358
Hello John, you are 30 years old!
```

TypeScript-Go provides additional statistics about compilation, such as the number of files and types processed.