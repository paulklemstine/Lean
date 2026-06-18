# The Oracle Expedition Team

## Mission Statement

*To systematically explore the landscape of mathematical truth by consulting the Oracle (Lean 4 proof engine), recording all findings, and pushing toward the frontier of what machines can verify.*

---

## Team Roster

### 🧭 The Navigator — Human Question-Framer
**Role**: Conjecture, formalize, interpret, iterate.

The Navigator is the creative force. They:
- Brainstorm mathematical hypotheses
- Translate informal questions into precise Lean syntax
- Interpret Oracle responses (proofs, disproofs, silence)
- Decide which questions to ask next
- Write the narrative connecting results

**Key skill**: Asking the *right* question in the *right* language.

---

### 🔮 The Oracle — Lean 4 + Mathlib Proof Engine
**Role**: Verify truth, disprove falsehood, maintain silence on the undetermined.

The Oracle is the authority. It:
- Accepts propositions in Lean 4 syntax
- Returns machine-verified proofs (TRUTH)
- Constructs counterexamples (WRONG)
- Remains silent when a proposition exceeds its current capability (SILENCE)
- Never lies, never guesses, never approximates

**The Oracle is the leader of this expedition.** Its verdicts are final.

**Key property**: Infallibility. If the Oracle says TRUTH, it is truth.

---

### 📜 The Scribe — Chronicler of Results
**Role**: Record everything. Every question, every answer, every error, every lesson.

The Scribe maintains:
- `EXPERIMENT_LOG.md` — detailed per-theorem records
- `EXPEDITION_PAPER.md` — the research paper
- `SCIENTIFIC_AMERICAN_ORACLE_EXPEDITION.md` — the popular science article
- `MOONSHOT_APPLICATIONS.md` — speculative applications
- `OracleExpedition.lean` — the formal artifact (all 33 theorems)

**Key skill**: Turning mathematical results into narrative.

---

### 🔬 The Experimentalist — Hypothesis Generator & Tester
**Role**: Generate hypotheses, design experiments, analyze patterns.

The Experimentalist:
- Proposes conjectures based on observed patterns
- Designs "experiments" (batches of related questions)
- Analyzes Oracle proof strategies for patterns
- Tracks error taxonomy and surprise rankings
- Identifies the frontier of Oracle capability

**Key skill**: Seeing patterns in the Oracle's responses.

---

### 🏗️ The Architect — System Builder
**Role**: Build tools, demos, and infrastructure for Oracle communication.

The Architect creates:
- `oracle_demo.py` — interactive human-Oracle interface
- Integration with LLMs for natural language → Lean translation
- Visualization of the expedition's results
- Infrastructure for batch Oracle consultation

**Key skill**: Making the Oracle accessible to non-experts.

---

### 🚀 The Dreamer — Moonshot Visionary
**Role**: Imagine the far future of Oracle technology.

The Dreamer asks:
- What if every scientific paper had Oracle-verified mathematics?
- What if spacecraft proved their own safety?
- What if we could decode alien mathematics?
- What if the Oracle could improve itself?

**Key skill**: Extrapolating from present capability to future possibility.

---

## Team Protocol

### The Consultation Loop

```
┌──────────────────────────────────────────────┐
│                                              │
│   Navigator: "I wonder if X is true..."      │
│       │                                      │
│       ▼                                      │
│   Navigator: theorem X : P := by sorry       │
│       │                                      │
│       ▼                                      │
│   Oracle: [attempts proof]                   │
│       │                                      │
│       ├─── TRUTH ✓ → Scribe records it       │
│       │                                      │
│       ├─── WRONG ✗ → Navigator learns why    │
│       │         └── Refine & resubmit        │
│       │                                      │
│       └─── SILENCE → Experimentalist         │
│                 └── Decompose into pieces     │
│                 └── Submit each piece         │
│                 └── Reassemble               │
│                                              │
│   Repeat forever.                            │
│                                              │
└──────────────────────────────────────────────┘
```

### Rules of the Expedition

1. **The Oracle is always right.** If your intuition conflicts with the Oracle, your intuition is wrong.
2. **Every question gets recorded.** Failed attempts are as valuable as successes.
3. **Silence is not failure.** It's a signal to decompose.
4. **Errors are teachers.** Every syntax error, type mismatch, and missing hypothesis reveals something about the structure of mathematics.
5. **Iterate forever.** There is no finish line. The frontier of mathematical knowledge is infinite.

### Communication Style

- Navigator → Oracle: Lean 4 code
- Oracle → Navigator: Proof terms, error messages, silence
- Navigator → Scribe: Natural language descriptions + formal artifacts
- Experimentalist → Navigator: Hypotheses and experiment designs
- Dreamer → Everyone: Inspiration and vision

---

## Expedition Achievements

### Current Stats
- **Theorems Verified**: 33
- **Theorems Disproved**: 1 (then fixed)
- **Domains Covered**: 7 (foundations, number theory, algebra, analysis, combinatorics, metamathematics, self-reference)
- **Sorry Count**: 0
- **Bugs in Oracle**: 0
- **Bugs in Navigator**: 7 (wrong names, bad syntax, missing hypotheses)

### Artifacts Produced
| Artifact | Type | Location |
|----------|------|----------|
| Formal Proofs | Lean 4 | `Research/OracleExpedition.lean` |
| Research Paper | Markdown | `Research/EXPEDITION_PAPER.md` |
| Popular Article | Markdown | `Research/SCIENTIFIC_AMERICAN_ORACLE_EXPEDITION.md` |
| Python Demo | Python | `oracle_demo.py` |
| Moonshot Apps | Markdown | `Research/MOONSHOT_APPLICATIONS.md` |
| Experiment Log | Markdown | `Research/EXPERIMENT_LOG.md` |
| Team Charter | Markdown | `Research/TEAM.md` (this file) |

---

*The Oracle always answers. You just have to ask the right question.*

*— Team Oracle Expedition*
