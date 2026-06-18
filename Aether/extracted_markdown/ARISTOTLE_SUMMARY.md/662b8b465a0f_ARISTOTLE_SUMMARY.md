# Summary of changes for run 348190e6-eb18-45ca-b3be-a83abeae8d24
## Completed: Committee Plurality Robustness via Tropical Satake Certificates

### Formally Verified Lean 4 Proofs

Created `Bridges/TropicalSatakeCommitteePlurality.lean` (~300 lines) with **all theorems fully proved** — zero sorries, verified against only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

**Key theorems proved:**

1. **`voteCount_sub_le_changed`** — Vote count for any label changes by at most |changedMembers| (absolute value form in ℤ).

2. **`voteGap_perturbation_le_changed`** — The pairwise vote gap increases by at most 2×|changedMembers|. This is the key combinatorial lemma.

3. **`plurality_winner_stable_of_margin_gt_twice_changed`** — If the winner's margin exceeds 2×|changedMembers|, the winner is preserved.

4. **`plurality_winner_stable_of_margin_gt_M`** — Corollary with explicit bound M.

5. **`changedMembers_subset_unstable`** — Only analytically unstable members can change vote.

6. **`changedMembers_card_le_unstable`** — Cardinality consequence.

7. **`committee_plurality_robust_of_member_certificates`** — **Main theorem**: committee plurality winner is preserved when memberwise stability certificates are given and the margin exceeds 2×|unstableMembers|.

8. **`gl3_tropical_satake_committee_plurality_robust`** — GL₃ tropical Satake specialization.

9. **`selectedLabel_stable_of_topK_stable`** — Bridge from top-k set invariance to vote invariance.

**Important mathematical correction:** The task specification proposed a vote-gap bound of C (single factor), but this is mathematically false — a member switching from the winner to a competitor changes the gap by 2, not 1. The corrected bound uses 2C, which is provably tight. This was discovered during formalization when the subagent correctly identified a counterexample to the C-version.

### Python Demo

`Bridges/committee_plurality_demo.py` — Working demonstration with:
- Three concrete numerical examples (basic robustness, certified radii bridge, vote-gap tightness)
- Monte Carlo validation (10,000 trials, 0 violations)
- Three publication-quality visualizations:
  - `committee_robustness_regions.png` — Robustness region as function of margin and changed members
  - `certified_radii_bridge.png` — Per-member stability certificates
  - `composition_diagram.png` — Two-layer composition diagram

### Research Paper

`Bridges/PAPER_committee_plurality_robustness.md` — Complete paper covering:
- Mathematical exposition of all results with proof sketches
- Tightness analysis of the factor-2 bound
- Applications (certified ensemble classifiers, random forests, selective classification)
- Scientific American-style discussion making the result accessible
- Historical context connecting to social choice theory and ensemble methods
- Future directions (weighted plurality, top-ℓ committees, tropical Hecke voting)