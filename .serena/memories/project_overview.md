# Lean Project Overview

## Purpose
A large-scale formal mathematics project in Lean 4, containing a consolidated theorem catalog with ~1,024 unique Lean files, ~24,509 declarations (~18,705 theorems/lemmas, ~4,957 definitions, ~843 structures/classes/inductives), and ~212,535 lines of Lean code.

The project covers a wide range of mathematical domains: algebra, analysis, category theory, combinatorics, complexity theory, cryptography, geometry, information theory, logic, machine learning, number theory, physics, probability, topology, tropical geometry, and more. It also includes research-oriented areas like EML (Emergent Mathematical Language), Pythagorean quadruples factoring, Sheffer AI, and speculative mathematics.

## Tech Stack
- **Language**: Lean 4 (v4.28.0)
- **Build System**: Lake (Lean's build tool)
- **Key Dependency**: Mathlib v4.28.0 (`leanprover-community/mathlib4`)

## Repository Structure
- Root directory contains only `.git/`, `.serena/`, and `Catalog/`
- `Catalog/` is the main codebase — a deduplicated, self-contained library
- All imports use `Catalog.*` module paths
- `Catalog/lakefile.toml` defines 33+ library targets (Algebra, Analysis, EML, Pythagorean, etc.)
- `Catalog/CATALOG.md` — master catalog with statistics and declaration listings
- `Catalog/DECLARATION_INDEX.md` — alphabetical index of all 19,614 unique declaration names