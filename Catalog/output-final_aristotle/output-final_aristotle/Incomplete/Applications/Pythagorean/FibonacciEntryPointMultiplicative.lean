import Mathlib
import Speculative.AutoResearch.FibonacciEntryPointCharacterization

/-! # The multiplicative structure of the Fibonacci entry point

For a modulus `m`, the **entry point** (rank of apparition) `α(m)` is the least
positive index `k` with `m ∣ F(k)` (`FibEntryChar.fibEntryPt`).  The companion file
`FibonacciEntryPointCharacterization.lean` established the *ideal-structure theorem*
`fib_dvd_iff_entryPt_dvd : m ∣ F(k) ↔ α(m) ∣ k` and the *lcm law for two coprime
factors* `fibEntryPt_mul_coprime`.

This file develops the **multiplicative and lattice structure** of `α`:

* `entryPt_exists_of_dvd` / `fibEntryPt_dvd_of_dvd` — `α` is *monotone under
  divisibility*: if `a ∣ b` and `b` has an entry point, then so does `a`, and
  `α(a) ∣ α(b)`.  Divisibility of moduli is reflected as divisibility of entry
  points.
* `fibEntryPt_one` / `fibEntryPt_eq_one_iff` — `α(1) = 1`, and for any modulus with
  an entry point, `α(m) = 1 ↔ m ∣ 1`; the entry point detects the trivial modulus.
* `fib_dvd_lcm_of_dvd_left` — the apparition index set `{k | m ∣ F k}` is closed
  under `lcm` (it is already closed under `gcd` via `fib_dvd_gcd_of_dvd`), confirming
  it is a sublattice of `(ℕ, ∣)` — in fact the principal ideal `(α m)`.
* `fibEntryPt_prod_coprime` — the **finite lcm law**: for a finite family of
  pairwise-coprime moduli, each with an entry point,
  `α(∏ i, m i) = lcm over i of α(m i)`.  This is the engine that reconstructs
  `α(m)` from `α` on the prime-power factors of `m`, generalizing the two-factor
  `fibEntryPt_mul_coprime`.

## Catalog synthesis

This builds directly on `Speculative.AutoResearch.FibonacciEntryPointCharacterization`
(`fibEntryPt`, `fib_dvd_iff_entryPt_dvd`, `fibEntryPt_pos`, `fib_dvd_fibEntryPt`,
`fib_dvd_gcd_of_dvd`, `fibEntryPt_mul_coprime`) and connects it to the
primitive-divisor viewpoint of `Applications.FibonacciPrimitiveDivisors`
(`dvd_fib_iff_index_dvd_of_primitive`, `simultaneous_apparition`) and the apparition
lattice of `Novelty.FibApparitionExistence`.  The new content is the *lattice and
multiplicative algebra* of the entry-point map `α : ℕ → ℕ`, which those files left
as one-off two-element statements.

-- !-- Lab Notebook -- !--
-- !-- Hypothesis: the entry-point map α is a divisibility-preserving, lcm-multiplicative
--     map on coprime factors, so the whole apparition index set is governed by α as a
--     principal ideal and α(m) is reconstructible from the prime-power factorization. -- !--
-- !-- Result: proved monotonicity under divisibility, the trivial-modulus characterization,
--     lcm-closure of the index set, and the finite lcm law for pairwise-coprime families. -- !--
-- !-- Insight: every statement reduces, via the ideal-structure theorem
--     `fib_dvd_iff_entryPt_dvd`, to elementary divisibility/lcm algebra in ℕ — the
--     Fibonacci-specific content is entirely localized in that one bridge lemma. -- !--
-- !-- Failure analysis: the only subtlety is producing the *existence* witness for the
--     product/sub-modulus before invoking the characterization; once existence is in hand
--     the divisibility bookkeeping is routine (Nat.lcm_dvd_iff, Finset.prod induction). -- !--
-- !-- End Lab Notebook -- !--
-/

namespace FibEntryChar

/-
If `a ∣ b` and `b` has an apparition index, then so does `a`.

!-- A witness `k` for `b` (b ∣ F k) is also a witness for `a` since `a ∣ b`. -- !--
-/
theorem entryPt_exists_of_dvd {a b : ℕ} (hab : a ∣ b)
    (hb : ∃ k, 0 < k ∧ b ∣ Nat.fib k) :
    ∃ k, 0 < k ∧ a ∣ Nat.fib k := by
  exact ⟨ hb.choose, hb.choose_spec.1, dvd_trans hab hb.choose_spec.2 ⟩

/-
**Monotonicity under divisibility.** If `a ∣ b` and `b` has an entry point, then
`α(a) ∣ α(b)`.

!-- b ∣ F(α b) and a ∣ b give a ∣ F(α b); then the characterization for a forces α(a) ∣ α(b). -- !--
-/
theorem fibEntryPt_dvd_of_dvd {a b : ℕ} (hab : a ∣ b)
    (hb : ∃ k, 0 < k ∧ b ∣ Nat.fib k) :
    fibEntryPt a ∣ fibEntryPt b := by
  obtain ⟨ k, hk ⟩ := hb;
  convert fib_dvd_iff_entryPt_dvd _ ( fibEntryPt b ) |>.1 _;
  · exact ⟨ k, hk.1, dvd_trans hab hk.2 ⟩;
  · exact dvd_trans hab ( fib_dvd_fibEntryPt ⟨ k, hk.1, hk.2 ⟩ )

/-
The entry point of `1` is `1` (since `1 ∣ F 1`).
-/
theorem fibEntryPt_one : fibEntryPt 1 = 1 := by
  unfold fibEntryPt;
  split_ifs <;> simp_all +decide [ Nat.find_eq_iff ];
  cases ‹∀ x : ℕ, x = 0› 1

/-
For any modulus with an entry point, `α(m) = 1` exactly when `m` is trivial
(`m ∣ 1`).

!-- α(m)=1 ↔ m ∣ F 1 = 1 (via the characterization at k = 1, using F 1 = 1). -- !--
-/
theorem fibEntryPt_eq_one_iff {m : ℕ} (h : ∃ k, 0 < k ∧ m ∣ Nat.fib k) :
    fibEntryPt m = 1 ↔ m ∣ 1 := by
  constructor;
  · intro h1; have := fib_dvd_fibEntryPt h; aesop;
  · intro hm
    have := fib_dvd_iff_entryPt_dvd h 1
    simp_all +decide

/-
The apparition index set of `m` is closed under `lcm`: if `m ∣ F a` then
`m ∣ F (lcm a b)`.  Combined with closure under `gcd` (`fib_dvd_gcd_of_dvd`), this
exhibits `{k | m ∣ F k}` as a sublattice of `(ℕ, ∣)` — in fact the principal ideal
`(α m)`.  Only one of the two divisibilities is needed, since `a ∣ lcm a b`.

!-- a ∣ lcm a b gives F a ∣ F (lcm a b) (Nat.fib_dvd); compose with m ∣ F a. -- !--
-/
theorem fib_dvd_lcm_of_dvd_left {m a b : ℕ} (ha : m ∣ Nat.fib a) :
    m ∣ Nat.fib (Nat.lcm a b) :=
  dvd_trans ha (Nat.fib_dvd _ _ (Nat.dvd_lcm_left a b))

/-
A finite product of pairwise-coprime moduli, each with an entry point, again has an
entry point.

!-- Finset.induction: the inserted factor and the product are coprime, so a common index
(lcm of witnesses) is divided by their product. -- !--
-/
theorem entryPt_exists_prod_coprime {ι : Type*} (s : Finset ι) (m : ι → ℕ)
    (hcop : (s : Set ι).Pairwise (fun i j => Nat.Coprime (m i) (m j)))
    (hex : ∀ i ∈ s, ∃ k, 0 < k ∧ m i ∣ Nat.fib k) :
    ∃ k, 0 < k ∧ (∏ i ∈ s, m i) ∣ Nat.fib k := by
  revert hex;
  induction' s using Finset.induction with i s hi ih;
  exact fun _ => ⟨ 1, by decide, by simp +decide ⟩;
  simp +zetaDelta at *;
  intro x hx hx' hx''; obtain ⟨ k, hk, hk' ⟩ := ih ( hcop.mono ( by simp +decide ) ) hx''; use Nat.lcm x k; simp_all +decide;
  · refine' Nat.Coprime.mul_dvd_of_dvd_of_dvd _ _ _;
    · exact Nat.Coprime.prod_right fun j hj => hcop ( by aesop ) ( by aesop ) ( by aesop );
    · exact dvd_trans hx' ( Nat.fib_dvd _ _ ( Nat.dvd_lcm_left _ _ ) );
    · exact dvd_trans hk' ( Nat.fib_dvd _ _ ( Nat.dvd_lcm_right _ _ ) );
  · exact Classical.decEq ι

/-
**Finite lcm law.** For a finite family of pairwise-coprime moduli, each with an
entry point, the entry point of the product is the lcm of the entry points.

!-- Finset.induction: the inserted factor is coprime to the product (pairwise coprimality
+ Nat.Coprime.prod_right), so fibEntryPt_mul_coprime applies and lcm distributes. -- !--
-/
theorem fibEntryPt_prod_coprime {ι : Type*} (s : Finset ι) (m : ι → ℕ)
    (hcop : (s : Set ι).Pairwise (fun i j => Nat.Coprime (m i) (m j)))
    (hex : ∀ i ∈ s, ∃ k, 0 < k ∧ m i ∣ Nat.fib k) :
    fibEntryPt (∏ i ∈ s, m i) = s.lcm (fun i => fibEntryPt (m i)) := by
  have h_exists : ∃ k, 0 < k ∧ (∏ i ∈ s, m i) ∣ Nat.fib k :=
    entryPt_exists_prod_coprime s m hcop hex
  refine' Nat.dvd_antisymm _ _;
  · have h_div : ∀ i ∈ s, m i ∣ Nat.fib (Finset.lcm s (fun i => fibEntryPt (m i))) := by
      intro i hi;
      exact fib_dvd_iff_entryPt_dvd ( hex i hi ) _ |>.2 ( Finset.dvd_lcm hi );
    apply (fib_dvd_iff_entryPt_dvd h_exists (Finset.lcm s (fun i => fibEntryPt (m i)))).mp;
    convert Finset.lcm_dvd h_div using 1;
    have h_lcm : ∀ {t : Finset ι}, (∀ i ∈ t, ∀ j ∈ t, i ≠ j → Nat.Coprime (m i) (m j)) → Finset.lcm t m = ∏ i ∈ t, m i :=
      fun {t} a => Finset.lcm_eq_prod a
    exact Eq.symm ( h_lcm fun i hi j hj hij => hcop hi hj hij );
  · refine' Finset.lcm_dvd fun i hi => fibEntryPt_dvd_of_dvd _ _;
    · exact Finset.dvd_prod_of_mem _ hi;
    · exact h_exists

end FibEntryChar