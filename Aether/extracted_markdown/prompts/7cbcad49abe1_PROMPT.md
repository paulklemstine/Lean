## Task: Formalize Submodularity of Graph Cut Functional

Create a complete, compilable Lean 4 file proving the submodularity inequality for a discrete graph cut functional. This is a discrete combinatorial analogue of the Ryu–Takayanagi holographic entropy bound.

### Definitions

Variable `{V : Type*} [Fintype V] [DecidableEq V]` and a weight function `w : V → V → ℝ`.

```
def cut (w : V → V → ℝ) (A : Finset V) : ℝ :=
  ∑ u : V, ∑ v : V, if u ∈ A ∧ v ∉ A then w u v else 0
```

Define `mutualInformation (w : V → V → ℝ) (A B : Finset V) : ℝ :=
  cut w A + cut w B - cut w (A ∪ B) - cut w (A ∩ B)`.

Assume throughout: `(hw : ∀ u v, 0 ≤ w u v)` and optionally `(hw_sym : ∀ u v, w u v = w v u)`.

### Required Theorems (in order of dependency)

1. **cut_nonneg**: `0 ≤ cut w A` — direct from hw and sum of nonneg.

2. **cut_empty**: `cut w ∅ = 0` and **cut_univ**: `cut w univ = 0` — trivial simplifications.

3. **cut_compl**: If `hw_sym`, then `cut w Aᶜ = cut w A` — symmetry argument.

4. **cut_submodular** (THE MAIN RESULT): `cut w (A ∪ B) + cut w (A ∩ B) ≤ cut w A + cut w B`.

   **Proof strategy — this is critical, follow it exactly:**
   
   For each pair `(u, v)`, define the pointwise contribution:
   `f u v := if u ∈ A ∧ v ∉ A then w u v else 0`
   
   The key lemma (prove this FIRST as a separate lemma):
   For any `u v : V`:
   `(if u ∈ A ∪ B ∧ v ∉ A ∪ B then w u v else 0) + (if u ∈ A ∩ B ∧ v ∉ A ∩ B then w u v else 0)
   ≤ (if u ∈ A ∧ v ∉ A then w u v else 0) + (if u ∈ B ∧ v ∉ B then w u v else 0)`
   
   **How to prove this lemma**: By `split` on each of the four membership conditions `(u ∈ A)`, `(v ∈ A)`, `(u ∈ B)`, `(v ∈ B)`. There are 16 cases. In each case, all four booleans are decided, so all `if-then-else` expressions simplify to either `w u v` or `0`. The inequality becomes `0 ≤ w u v` (from `hw`), `0 ≤ 0`, or `0 ≤ w u v + 0`, etc. Use `simp [Finset.mem_union, Finset.mem_inter, Finset.not_mem_union, Finset.not_mem_inter]` and `split` liberally. The `omega` or `linarith` tactic should close each branch after simplification.
   
   Then sum this pointwise inequality over all `(u, v)` to get the global result using `Finset.sum_add_sum_le_sum_add_sum` or manual `Finset.sum_le_sum` reasoning.

5. **cut_union_le**: `cut w (A ∪ B) ≤ cut w A + cut w B` — derive as corollary of submodularity plus `0 ≤ cut w (A ∩ B)`.

6. **mutualInformation_nonneg**: `0 ≤ mutualInformation w A B` — direct from submodularity by rearrangement.

### Implementation Notes

- Use `Finset.sum` over `Finset.univ` for the outer sums (since V is Fintype).
- The pointwise lemma is the crux. Do NOT try to prove submodularity by induction on finsets. The pointwise approach is elementary and complete.
- Use `by split <;> simp <;> linarith [hw u v]` as the closing pattern for each case.
- Keep the file under 300 lines. Do NOT include any sorry or incomplete proofs.
- Import `Mathlib.Data.Real.Basic` and `Mathlib.Data.Fintype.Basic` and `Mathlib.Algebra.BigOperators.Group.Finset.Basic`.
- Place everything in namespace `DiscreteHolographicEntropy`.
- Use `open Finset` for convenience.