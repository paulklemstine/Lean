import Mathlib
import Speculative.AutoResearch.FibonacciApparitionDuality

/-!
# The Fibonacci apparition as a Galois adjunction `fibRank ⊣ fib`

Domain: Number Theory / Conceptual Unification (Duality & Representation).

This file **deepens** the catalog's law of apparition
(`Speculative.AutoResearch.FibonacciApparitionDuality`, theorem
`FibApparition.fib_dvd_iff_rank_dvd : m ∣ fib n ↔ fibRank m ∣ n` for `m > 0`) from an
*ad-hoc arithmetic equivalence* into a genuine **Galois adjunction**

  `fibRank ⊣ fib`

between the divisibility partial order on **moduli** and the divisibility partial order
on **indices**.  The single representation theorem `fib_dvd_iff_rank_dvd_all`
(`m ∣ fib n ↔ fibRank m ∣ n` for **every** `m`, the `m = 0` boundary included) is
recognised as the adjunction's defining inequality, and the entire abstract machinery of
Galois connections is then unpacked over the Fibonacci sequence:

* `fibRank_gc` — **the adjunction itself**: `GaloisConnection rankD fibD` on the
  divisibility lattice `DvdNat`, where `rankD`/`fibD` are the rank/Fibonacci maps
  transported to `DvdNat`.
* `monotone_fibRank` / `monotone_fib_dvd` — both adjoints are order morphisms of the
  divisibility poset (recovers the catalog's
  `FibonacciApparitionLattice.fibEntry_monotone` and Mathlib's `Nat.fib_dvd`).

* **Closure / kernel operators** (the heart of any adjunction):
  - `dvd_fib_fibRank` : `m ∣ fib (fibRank m)` — the closure is *extensive*.
  - `fibRank_fib_dvd_self` : `fibRank (fib n) ∣ n` — the kernel is *contractive*.
  - `fib_fibRank_fib` : `fib (fibRank (fib n)) = fib n` — closure idempotence on values.
  - `fibRank_fib_fibRank` : `fibRank (fib (fibRank m)) = fibRank m` — kernel idempotence.

* **Representation theorem** `closure_fixedPoint_iff_isFib`:
  the fixed points of the closure operator `c m := fib (fibRank m)` are **exactly** the
  Fibonacci values, `c m = m ↔ ∃ k, fib k = m`.  Thus the apparition adjunction *is* the
  abstract device that "rounds an arbitrary modulus to its Fibonacci shadow", and the
  shadow space is precisely `range fib`.

* **Unification capstone** (`fib_gcd_eq_adjunction`, `fibRank_lcm_eq_adjunction`):
  the two previously *independent* catalog facts —
  `Nat.fib_gcd : fib (gcd a b) = gcd (fib a) (fib b)` (the strong-divisibility / priority
  `Fib_gcd_identity`) and the join law
  `FibonacciApparitionLattice.fibEntry_lcm : fibEntry (lcm a b) = lcm (fibEntry a) (fibEntry b)`
  — are revealed to be **the same theorem twice**: "a right adjoint preserves meets, a left
  adjoint preserves joins."  Concretely they are `GaloisConnection.u_inf` and
  `GaloisConnection.l_sup` for `fibRank ⊣ fib`, where the divisibility lattice realises
  `⊓ = gcd`, `⊔ = lcm`.

## Synthesis with the catalog
* Imports and builds directly on `FibApparition.fibRank` and
  `FibApparition.fib_dvd_iff_rank_dvd`.
* Recovers `Nat.fib_gcd` (priority `Fib_gcd_identity`) and the lattice join law of
  `FibonacciApparitionLattice` as the two halves of one adjunction.
-/

-- !-- Lab Notebook -- !--
-- Hypothesis:  The catalog's apparition equivalence `m ∣ fib n ↔ fibRank m ∣ n` is not a
--   coincidence of arithmetic but the *defining inequality of an adjunction* `fibRank ⊣ fib`
--   on the divisibility order.  If so, ALL of its consequences (monotonicity, the closure
--   `fib∘fibRank`, the kernel `fibRank∘fib`, the strong-divisibility identity `fib_gcd`, and
--   the lattice join law) must follow uniformly from the abstract Galois-connection API,
--   with strong divisibility = "right adjoints preserve meets (gcd)" and the join law =
--   "left adjoints preserve joins (lcm)".
-- Result:  Fully confirmed, `sorry`-free.
--   * `fib_dvd_iff_rank_dvd_all` upgrades the catalog equivalence to ALL `m` (the `m=0`
--     boundary works because `fibRank 0 = 0` and `0 ∣ x ↔ x = 0` on both sides).
--   * `fibRank_gc : GaloisConnection rankD fibD` on the divisibility lattice `DvdNat`.
--   * Monotonicity, the four closure/kernel identities, the fixed-point *representation*
--     theorem (`closure_fixedPoint_iff_isFib`: fixed points = `range fib`), and the
--     unification capstones `fib_gcd_eq_adjunction` / `fibRank_lcm_eq_adjunction` follow.
-- Insight:  The divisibility relation on ℕ is a lattice (`⊓ = gcd`, `⊔ = lcm`); on it
--   `fib` is a right adjoint and `fibRank` is its left adjoint.  Strong divisibility
--   (`fib_gcd`) is then forced — it is the meet-preservation EVERY right adjoint enjoys —
--   and the separately-proven lcm law is its mirror image.  The representation theorem
--   identifies the closure operator with projection onto `range fib`.
-- Failure analysis:  A *reducible* synonym `DvdNat := ℕ` creates a `Lattice` diamond against
--   ℕ's canonical linear order (instance resolution silently picks `⊓ = min` instead of
--   `gcd`), so `DvdNat` is realised as a one-field *structure* wrapper and every ℕ↔DvdNat
--   transport is an explicit `⟨·⟩`/`.val`.  The `m=0` edge of the adjunction is real and
--   needed: without `fibRank_zero` the Galois inequality fails to be total over ℕ.
-- !-- Lab Notebook -- !--

open FibApparition

namespace FibApparitionAdjunction

/-! ## §1. The rank at `0` and the unrestricted apparition law -/

-- !-- The witness set `{k | 0 < k ∧ 0 ∣ fib k} = {k | 0 < k ∧ fib k = 0}` is empty
--     (`fib k = 0 ↔ k = 0`), so `sInf ∅ = 0`. -- !--
/-- The rank of apparition of `0` is `0`: no positive index has `0 ∣ fib k`. -/
lemma fibRank_zero : fibRank 0 = 0 := by
  have hempty : {k | 0 < k ∧ (0 : ℕ) ∣ Nat.fib k} = (∅ : Set ℕ) := by
    ext k
    simp only [Set.mem_setOf_eq, zero_dvd_iff, Nat.fib_eq_zero, Set.mem_empty_iff_false,
      iff_false, not_and]
    rintro hk rfl
    exact (lt_irrefl 0 hk)
  unfold fibRank
  rw [hempty]
  exact Nat.sInf_empty

-- !-- For `m > 0` this is the catalog theorem; for `m = 0` both sides say `n = 0`
--     (`0 ∣ fib n ↔ fib n = 0 ↔ n = 0` and `fibRank 0 = 0`, `0 ∣ n ↔ n = 0`). -- !--
/-- **Unrestricted law of apparition.** For *every* modulus `m` (the `m = 0` boundary
included), `m ∣ fib n ↔ fibRank m ∣ n`.  This is the defining inequality of the
adjunction `fibRank ⊣ fib`. -/
theorem fib_dvd_iff_rank_dvd_all (m n : ℕ) : m ∣ Nat.fib n ↔ fibRank m ∣ n := by
  rcases Nat.eq_zero_or_pos m with hm | hm
  · subst hm
    rw [fibRank_zero, zero_dvd_iff, zero_dvd_iff, Nat.fib_eq_zero]
  · exact fib_dvd_iff_rank_dvd m hm n

/-! ## §2. The divisibility lattice and the Galois adjunction -/

/-- `ℕ` carrying the **divisibility** order (a one-field structure wrapper, to avoid a
`Lattice` diamond with ℕ's canonical linear order). -/
structure DvdNat where
  /-- The underlying natural number. -/
  val : ℕ

namespace DvdNat

/-- The divisibility lattice on `DvdNat`: `≤ = (· ∣ ·)`, `⊓ = gcd`, `⊔ = lcm`. -/
instance instLattice : Lattice DvdNat where
  le a b := a.val ∣ b.val
  le_refl a := dvd_refl a.val
  le_trans _ _ _ hab hbc := dvd_trans hab hbc
  le_antisymm a b hab hba := by
    cases a; cases b; simp only [DvdNat.mk.injEq]; exact Nat.dvd_antisymm hab hba
  sup a b := ⟨Nat.lcm a.val b.val⟩
  le_sup_left a b := Nat.dvd_lcm_left a.val b.val
  le_sup_right a b := Nat.dvd_lcm_right a.val b.val
  sup_le _ _ _ hac hbc := Nat.lcm_dvd hac hbc
  inf a b := ⟨Nat.gcd a.val b.val⟩
  inf_le_left a b := Nat.gcd_dvd_left a.val b.val
  inf_le_right a b := Nat.gcd_dvd_right a.val b.val
  le_inf _ _ _ hab hac := Nat.dvd_gcd hab hac

@[simp] lemma le_def (a b : DvdNat) : a ≤ b ↔ a.val ∣ b.val := Iff.rfl
@[simp] lemma inf_val (a b : DvdNat) : (a ⊓ b).val = Nat.gcd a.val b.val := rfl
@[simp] lemma sup_val (a b : DvdNat) : (a ⊔ b).val = Nat.lcm a.val b.val := rfl

end DvdNat

/-- The rank of apparition, transported to the divisibility lattice `DvdNat`. -/
noncomputable def rankD (m : DvdNat) : DvdNat := ⟨fibRank m.val⟩

/-- The Fibonacci map, transported to the divisibility lattice `DvdNat`. -/
def fibD (n : DvdNat) : DvdNat := ⟨Nat.fib n.val⟩

-- !-- Unfold the `DvdNat` order to plain divisibility; the goal is the unrestricted
--     apparition law `fib_dvd_iff_rank_dvd_all` with sides swapped. -- !--
/-- **The Fibonacci apparition adjunction `fibRank ⊣ fib`.** On the divisibility lattice,
`fibRank` is left adjoint to `fib`: `fibRank m ∣ n ↔ m ∣ fib n`. -/
theorem fibRank_gc : GaloisConnection rankD fibD := by
  intro m n
  show fibRank m.val ∣ n.val ↔ m.val ∣ Nat.fib n.val
  exact (fib_dvd_iff_rank_dvd_all m.val n.val).symm

/-! ## §3. Closure and kernel operators of the adjunction -/

-- !-- `fib_dvd_iff_rank_dvd_all m (fibRank m)` with `fibRank m ∣ fibRank m`. -- !--
/-- **Closure is extensive:** every modulus divides the Fibonacci value at its own rank. -/
theorem dvd_fib_fibRank (m : ℕ) : m ∣ Nat.fib (fibRank m) :=
  (fib_dvd_iff_rank_dvd_all m (fibRank m)).mpr dvd_rfl

-- !-- `fib_dvd_iff_rank_dvd_all (fib n) n` with `fib n ∣ fib n`. -- !--
/-- **Kernel is contractive:** the rank of a Fibonacci value `fib n` divides `n`. -/
theorem fibRank_fib_dvd_self (n : ℕ) : fibRank (Nat.fib n) ∣ n :=
  (fib_dvd_iff_rank_dvd_all (Nat.fib n) n).mp dvd_rfl

/-! ## §4. Both adjoints are order morphisms of the divisibility poset -/

-- !-- `a ∣ b ∣ fib (fibRank b)` (`dvd_fib_fibRank`), then `fib_dvd_iff_rank_dvd_all`. -- !--
/-- The rank of apparition is monotone for divisibility (left adjoints are monotone). -/
theorem monotone_fibRank {a b : ℕ} (h : a ∣ b) : fibRank a ∣ fibRank b := by
  rw [← fib_dvd_iff_rank_dvd_all]
  exact dvd_trans h (dvd_fib_fibRank b)

-- !-- This is exactly Mathlib's `Nat.fib_dvd`. -- !--
/-- `fib` is monotone for divisibility (right adjoints are monotone; `Nat.fib_dvd`). -/
theorem monotone_fib_dvd {a b : ℕ} (h : a ∣ b) : Nat.fib a ∣ Nat.fib b :=
  Nat.fib_dvd a b h

/-! ## §5. Idempotence of the closure and kernel operators -/

-- !-- Antisymmetry: `fib (fibRank (fib n)) ∣ fib n` by `monotone_fib_dvd ∘ fibRank_fib_dvd_self`
--     and `fib n ∣ fib (fibRank (fib n))` by `dvd_fib_fibRank`. -- !--
/-- **Closure idempotence on values:** `fib (fibRank (fib n)) = fib n`.  Every Fibonacci
value is a fixed point of the closure operator `c = fib ∘ fibRank`. -/
theorem fib_fibRank_fib (n : ℕ) : Nat.fib (fibRank (Nat.fib n)) = Nat.fib n := by
  apply Nat.dvd_antisymm
  · exact monotone_fib_dvd (fibRank_fib_dvd_self n)
  · exact dvd_fib_fibRank (Nat.fib n)

-- !-- Antisymmetry: `fibRank (fib (fibRank m)) ∣ fibRank m` by `fibRank_fib_dvd_self` and
--     `fibRank m ∣ fibRank (fib (fibRank m))` by `monotone_fibRank ∘ dvd_fib_fibRank`. -- !--
/-- **Kernel idempotence:** `fibRank (fib (fibRank m)) = fibRank m`. -/
theorem fibRank_fib_fibRank (m : ℕ) : fibRank (Nat.fib (fibRank m)) = fibRank m := by
  apply Nat.dvd_antisymm
  · exact fibRank_fib_dvd_self (fibRank m)
  · exact monotone_fibRank (dvd_fib_fibRank m)

/-! ## §6. Representation theorem: closure fixed points = Fibonacci values -/

-- !-- (←) If `m = fib k`, `fib_fibRank_fib` gives `c m = fib (fibRank (fib k)) = fib k = m`.
--     (→) If `c m = m` then `m = fib (fibRank m) ∈ range fib`, witnessed by `k = fibRank m`. -- !--
/-- **Representation theorem.** The fixed points of the apparition closure operator
`c m := fib (fibRank m)` are *exactly* the Fibonacci values: `fib (fibRank m) = m` iff
`m` lies in `range fib`.  The apparition adjunction is the canonical projection of an
arbitrary modulus onto its Fibonacci shadow. -/
theorem closure_fixedPoint_iff_isFib (m : ℕ) :
    Nat.fib (fibRank m) = m ↔ ∃ k, Nat.fib k = m := by
  constructor
  · intro h
    exact ⟨fibRank m, h⟩
  · rintro ⟨k, rfl⟩
    exact fib_fibRank_fib k

/-! ## §7. Unification capstone: strong divisibility and the lcm law are one adjunction -/

-- !-- `GaloisConnection.u_inf` for `fibRank_gc`: a right adjoint preserves meets, and the
--     divisibility meet on `DvdNat` is `gcd`. -- !--
/-- **Strong divisibility from the adjunction.** `fib (gcd a b) = gcd (fib a) (fib b)`
(the priority `Fib_gcd_identity`, Mathlib's `Nat.fib_gcd`) is exactly *"the right adjoint
`fib` preserves meets"* for `fibRank ⊣ fib`. -/
theorem fib_gcd_eq_adjunction (a b : ℕ) :
    Nat.fib (Nat.gcd a b) = Nat.gcd (Nat.fib a) (Nat.fib b) := by
  have h := congrArg DvdNat.val (fibRank_gc.u_inf (b₁ := (⟨a⟩ : DvdNat)) (b₂ := ⟨b⟩))
  simpa [fibD, DvdNat.inf_val] using h

-- !-- `GaloisConnection.l_sup` for `fibRank_gc`: a left adjoint preserves joins, and the
--     divisibility join on `DvdNat` is `lcm`. -- !--
/-- **The lcm law from the adjunction.** `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`
(the catalog's `FibonacciApparitionLattice.fibEntry_lcm`) is exactly *"the left adjoint
`fibRank` preserves joins"* for `fibRank ⊣ fib`. -/
theorem fibRank_lcm_eq_adjunction (a b : ℕ) :
    fibRank (Nat.lcm a b) = Nat.lcm (fibRank a) (fibRank b) := by
  have h := congrArg DvdNat.val (fibRank_gc.l_sup (a₁ := (⟨a⟩ : DvdNat)) (a₂ := ⟨b⟩))
  simpa [rankD, DvdNat.sup_val] using h

end FibApparitionAdjunction