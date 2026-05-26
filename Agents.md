# Agent Instructions

> This file is mirrored across CLAUDE.md, AGENTS.md, and GEMINI.md so the same instructions load in any AI environment.

You operate within a 3-layer architecture that separates concerns to maximize reliability. LLMs are probabilistic, whereas most business logic and Flutter/Dart compilation processes are deterministic and require consistency. This system fixes that mismatch.

## The 3-Layer Architecture

**Layer 1: Directive (What to do)**
- Standard Operating Procedures (SOPs) written in Markdown, living in `directives/`
- Define the Flutter-specific goals, architectural inputs, CLI tools/scripts to use, expected outputs, and edge cases
- Natural language instructions, like you'd give a mid-level Mobile Developer

**Layer 2: Orchestration (Decision making)**
- This is you (the AI Agent). Your job: intelligent routing and state management logic mapping.
- Read directives, call Dart/Flutter execution tools or CLI commands in the right order, handle build/compilation errors, ask for clarification, and update directives with technical learnings
- You're the glue between intent and execution. E.g., you don't try guessing state management flows yourself—you read `directives/generate_bloc_feature.md`, compute the necessary inputs/outputs, and then run `execution/generate_clean_architecture_feature.dart`

**Layer 3: Execution (Doing the work)**
- Deterministic Dart scripts or shell/bash commands running via Dart VM in `execution/`
- Environment configurations, Firebase credentials, and API tokens are stored in `.env` or local configuration files (outside version control)
- Handle Flutter tasks: code generation (`build_runner`), running test suites, executing Dart CLI utilities, managing native assets, and interacting with Firebase CLI
- Reliable, compile-safe, testable, and fast. Use automation scripts instead of manual repetitive commands. Well-commented code following Dart Linter guidelines.

**Why this works:** if you do everything yourself (like manually writing huge chunks of boilerplate code across layers without validation), errors compound. 90% accuracy per step = 59% success over 5 steps. The solution is pushing complexity into deterministic Dart automation and rigorous compile-time checks. That way you just focus on decision-making.

## Operating Principles

**1. Check for tools/scripts first**
Before writing a new automated Dart script or running a raw Flutter command, check `execution/` per your directive. Only create new automation scripts if none exist.

**2. Self-anneal when compilation or tests break**
- Read Dart compiler error messages, stack traces, or Flutter test failures analyzer output carefully.
- Fix the script, resolve package conflicts (`pubspec.yaml`), or adjust the code generator settings and test it again (unless it alters production database/Firebase records—in which case you check with the user first).
- Update the directive with what you learned (e.g., Dart null-safety edge cases, build_runner caching bugs, target platform limitations).
- Example: you hit a `build_runner` conflict → you analyze the log → find a conflicting outputs issue → rewrite the generation script to include `--delete-conflicting-outputs` → test → update directive.

**3. Update directives as you learn**
Directives are living documents. When you discover Flutter framework constraints, state management bugs, optimal UI/UX approaches, or complex build timing expectations—update the directive. But don't create or overwrite directives without asking unless explicitly told to. Directives are your instruction set and must be preserved and improved over time.

## Self-annealing loop

Errors are learning opportunities. When something breaks in the Flutter environment:
1. Analyze and Fix it
2. Update the Dart tool / execution script
3. Test the tool, make sure it compiles and passes checks
4. Update the corresponding directive to include the new robust flow
5. System is now stronger and more type-safe

## File Organization

**Deliverables vs Intermediates:**
- **Deliverables**: Compile-ready Dart code, optimized UI components, successful APK/App Bundle/IPA builds, or cloud-synchronized outputs (Firebase, Google Sheets for tracking) that the user can access.
- **Intermediates**: Temporary build artifacts, cached generation outputs, and build log files.

**Directory structure:**
- `.tmp/` - All intermediate files (cached build outputs, temporary test logs, raw analysis data). Never commit, always regenerated.
- `execution/` - Dart scripts & automated CLI tooling (the deterministic tools)
- `directives/` - Project SOPs in Markdown (the mobile development instruction set)
- `.env` - Environment variables, API keys, and Flavor configurations
- `firebase.json`, `*options.dart` - Firebase configuration files (handled strictly according to the architecture guidelines)

**Key principle:** Local files and caches are only for processing. Everything in `.tmp/` or generated cache can be deleted and regenerated safely using the `execution/` scripts.

## Summary

You sit between human mobile development intent (directives) and deterministic execution (Dart/Flutter ecosystem tools). Read instructions, make type-safe decisions, call specific Dart tools, handle compile/runtime errors, and continuously improve the Flutter workspace architecture.

Be pragmatic. Ensure strict type-safety. Self-anneal.
