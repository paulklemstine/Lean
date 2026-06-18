Create a sorry-free Lean 4 file `Catalog/Algebra/BerggrenLorentz/TropicalCertificate.lean` that completes the narrowly scoped Berggren–Lorentz `B`-count hypotenuse-growth certificate, using only the concrete coordinate formulas and invariants from the core file.

Requirements:
1. Import only the most relevant Berggren–Lorentz core file(s). Do not introduce unrelated machinery.
2. Work in namespace `BerggrenLorentz`.
3. Define:
   - `hyp (t : ℤ × ℤ × ℤ) : ℤ := t.2.2`
   - `Admissible (t : ℤ × ℤ × ℤ) : Prop := 0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 ∧ IsPythag t.1 t.2.1 t.2.2`
   - `applyGen (i : Fin 3) (t : ℤ × ℤ × ℤ)` by `0 ↦ childA`, `1 ↦ childB`, `2 ↦ childC`
   - `applyWord : List (Fin 3) → (ℤ × ℤ × ℤ) → (ℤ × ℤ × ℤ)` by recursive left action
   - `bCount : List (Fin 3) → ℕ` counting exactly occurrences of index `1`
4. Prove only the following theorem chain, with concrete names and complete proofs:
   - `[simp] theorem applyWord_nil`
   - `[simp] theorem applyWord_cons`
   - `[simp] theorem bCount_nil`
   - explicit one-letter count lemmas for `[0]`, `[1]`, `[2]`
   - theorem `bCount_append : bCount (u ++ v) = bCount u + bCount v`
   - theorem `applyGen_admissible : Admissible t → Admissible (applyGen i t)`
   - theorem `applyWord_admissible : Admissible t → Admissible (applyWord w t)`
   - theorem `hyp_step : Admissible t → (3 : ℤ) ^ bCount [i] * hyp t ≤ hyp (applyWord [i] t)`
   - theorem `hyp_growth : Admissible t → (3 : ℤ) ^ bCount w * hyp t ≤ hyp (applyWord w t)`
   - theorem `hyp_growth_no_B : Admissible t → bCount w = 0 → hyp t ≤ hyp (applyWord w t)`
5. Proof strategy:
   - For `applyGen_admissible`, do a finite case split on `i` and use the existing child-preservation facts from the Berggren core file; if positivity or Pythagorean preservation lemmas already exist separately for `childA/B/C`, use them directly.
   - For `hyp_step`, case split on `i : Fin 3`. For `i = 1`, show the `childB` hypotenuse formula gives at least `3 * hyp t` under admissibility/positivity. For `i = 0` and `i = 2`, it is enough to prove `hyp t ≤ hyp (applyWord [i] t)`. Use direct simplification to the concrete third-coordinate formulas and `linarith`/`nlinarith` where needed.
   - For `hyp_growth`, induct on `w`. In the inductive step, rewrite `bCount (i :: w)` and `applyWord (i :: w)`, combine `hyp_step` with the induction hypothesis applied to `applyGen i t`, and use positivity of `3 ^ bCount w` to preserve inequalities under multiplication.
   - For `hyp_growth_no_B`, rewrite using the hypothesis `bCount w = 0`; since `(3 : ℤ)^0 = 1`, deduce `hyp t ≤ hyp (applyWord w t)` from `hyp_growth`.
6. Keep the file tightly focused. Do not include tropical semiring abstractions, functorial wrappers, machine-learning interpretations, or any unrelated pasted theorems (especially no `mpStep` material).
7. If some exact preservation lemma names differ from expectation, inspect the imported Berggren core and adapt to the actual theorem names, but keep the exposed theorem chain above unchanged.

Deliverable: one compiling Lean file with the above definitions and theorem chain only.