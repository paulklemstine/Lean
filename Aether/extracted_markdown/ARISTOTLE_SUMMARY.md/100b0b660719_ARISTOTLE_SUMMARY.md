# Summary of changes for run ed25a0a1-db95-44e3-96ef-1c44fa829160
Created a compact, fully proved p-adic valuation depth stability core at `Algebra/PadicDepthCore/Core.lean`.

The file is self-contained (`import Mathlib`), placed in namespace `PadicDepthCore` with a fixed prime parameter `[hp : Fact (Nat.Prime p)]`, and contains exactly the four requested theorems, all completely proved (no placeholders, no `sorry`):

1. `le_iff_pow_dvd {n k : ℕ} (hn : n ≠ 0) : k ≤ padicValNat p n ↔ p ^ k ∣ n` — the divisibility criterion for valuation depth, wrapping Mathlib's `padicValNat_dvd_iff` into a clean API under the necessary `n ≠ 0` side condition.
2. `mul {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) : padicValNat p (m * n) = padicValNat p m + padicValNat p n` — multiplicativity on products of nonzero naturals.
3. `ultrametric_add {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) : min (padicValNat p m) (padicValNat p n) ≤ padicValNat p (m + n)` — the ultrametric lower bound, proved via the divisibility criterion (`p^a ∣ m`, `p^a ∣ n`, hence `p^a ∣ m+n`).
4. `isosceles {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) (h : padicValNat p m < padicValNat p n) : padicValNat p (m + n) = padicValNat p m` — the sharp isosceles law, proved by an `le_antisymm` combining the ultrametric lower bound with an upper bound argument.

Each theorem requires the minimal `m ≠ 0` / `n ≠ 0` hypotheses needed for the statement to be literally true in ℕ; these are documented in the module docstring, which lists only the theorems actually proved.

Verification: the file elaborates with no errors and no warnings, contains no `sorry`, and `#print axioms` confirms all four theorems depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.