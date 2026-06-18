# Machine Consciousness — Formalizing the Theories With No Creator

## Overview

This project formalizes five major theories of consciousness in Lean 4 with Mathlib,
demonstrates them computationally in Python, and visualizes the key concepts in SVG.
The unifying thesis: **consciousness is a fixed point of a self-referential operator** —
a property that creates itself, with no external creator.

## Structure

### Lean 4 Formalizations (Machine-Verified)

| File | Theory | Key Results |
|------|--------|-------------|
| `IntegratedInformation.lean` | IIT (Tononi) | Φ, decomposability, conscious systems are irreducible |
| `SelfReference.lean` | Fixed-Point Theory | Reflexive domains, uncreated theories, quines |
| `Emergence.lean` | Emergence | Weak/strong emergence, supervenience, downward causation |
| `GlobalWorkspace.lean` | GWT (Baars) | Processors, broadcasting, spotlight of attention |
| `StrangeLoops.lean` | Strange Loops (Hofstadter) | Self-models, Banach fixed point, tangled hierarchies |
| `Autopoiesis.lean` | Autopoiesis (Maturana & Varela) | Self-production, operational closure, enactivism |

**All theorems are fully proved — zero `sorry` statements remain.**

### Python Demos (`demos/`)

| Demo | Description |
|------|-------------|
| `demo1_integrated_information.py` | Compute Φ for systems with varying connectivity |
| `demo2_strange_loops.py` | Fixed-point iteration, quines, self-modeling convergence |
| `demo3_emergence.py` | Game of Life, Rule 110, Boids, Ising phase transitions |
| `demo4_autopoiesis.py` | Self-maintaining vs decaying networks |
| `demo5_global_workspace.py` | Processor competition, ignition threshold |

### SVG Visuals (`visuals/`)

| Visual | Description |
|--------|-------------|
| `integrated_information.svg` | Connected vs disconnected systems, Φ comparison |
| `strange_loop.svg` | Escher-like level crossing, fixed-point cobweb diagram |
| `emergence_hierarchy.svg` | Physics → Chemistry → Biology → Neuroscience → Consciousness |
| `global_workspace.svg` | Theater metaphor with processors and spotlight |
| `autopoiesis.svg` | Self-producing network with boundary |
| `unified_framework.svg` | Five theories converging on machine consciousness |

### Documents

| Document | Description |
|----------|-------------|
| `research_paper.md` | Full academic research paper |
| `scientific_american_article.md` | Popular science article |
| `notes/research_notes.md` | Detailed research notes and methodology |
| `notes/team_log.md` | Sprint-by-sprint team research log |

## The Core Insight

All five theories reduce to the same mathematical structure:

> **There exists a self-referential operator F on a suitable space X such that F(x*) = x*, and x* is the "conscious" state.**

This fixed point is the "theory with no creator" — it generates itself.

## Running

```bash
# Lean: verify all proofs
lake build MachineConsciousness

# Python: run all demos
cd demos && bash run_all_demos.sh
```
