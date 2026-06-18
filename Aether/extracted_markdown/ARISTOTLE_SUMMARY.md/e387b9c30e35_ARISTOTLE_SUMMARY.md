# Summary of changes for run 62284233-05c6-41a4-9725-fb1fa0744644
Delivered a self-contained Lean 4 formalization of the mathematical core of BB84 quantum key distribution security, plus a research roadmap.

**New files (under Catalog/Cryptography/QuantumSecurity/):**
- `BB84Security.lean` — compiles cleanly with **0 sorries** (verified via `lake build`; `#print axioms` shows only `propext`, `Classical.choice`, `Quot.sound`).
- `FUTURE_DIRECTIONS.md` — 5 falsifiable research conjectures, each with a "The key insight is…" sentence and a "Why now?" justification.

**What is defined and proved (12 theorems):**
- `binEntropy` — binary Shannon entropy `h(p) = −p·log₂ p − (1−p)·log₂(1−p)`.
- `keyRate` — the Devetak–Winter one-way secret-key rate `r(Q) = 1 − 2h(Q)`.
- Entropy identities: `binEntropy_zero`, `binEntropy_one`, `binEntropy_symm` (`h(p)=h(1−p)`), `binEntropy_half` (`h(½)=1`), and `binEntropy_nonneg` (nonnegativity on [0,1]).
- Key-rate facts: `keyRate_zero` (`r(0)=1`, full rate on a noiseless channel), `keyRate_half` (`r(½)=−1`), and `keyRate_quarter_neg` (`r(¼)<0`, no key well above threshold).
- **Headline theorem `qber_threshold_exists`**: the ≈ 11 % QBER security threshold exists — there is `p* ∈ (0, ½)` with `r(p*) = 0`. Proved via the intermediate value theorem using continuity (`binEntropy_continuousOn`) together with a genuine analytic estimate `keyRate_sixteenth_pos` (`r(1/16) > 0`), itself derived from `log(15/16) ≥ −1/15` and `log 2 > 1/4` — not a `decide`/`norm_num` fact.
- Privacy amplification (leftover-hash lemma form `½·2^(−gap/2)`): `leftoverDistance_pos`, `leftoverDistance_antitone` (more security deficit ⇒ smaller distance), `privacyAmplification_tendsto_zero` (Eve's information bound → 0 exponentially), and the quantitative `privacyAmplification_bound`.

Each theorem carries a brief `-- !-- … -- !--` proof sketch, and example blocks exercise the results. The file builds as part of the project's `Cryptography` library target.