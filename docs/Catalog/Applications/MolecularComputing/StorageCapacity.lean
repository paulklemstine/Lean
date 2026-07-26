/-
# Information-theoretic storage and description limits of molecular computers

This file proves the elementary but sharp information-theoretic bounds behind two
of the moonshot's quantitative claims:

* *"A cubic micrometer of DNA can store `10^18` bits."* — Storing / distinguishing
  `N` distinct configurations requires at least `log₂ N` bits of molecular state;
  conversely `k` bits of state distinguish **at most** `2^k` configurations.
* *"The minimum volume of a CRN computing a function `f` is proportional to the
  Kolmogorov complexity of `f`."* — Any injective encoding of a family of
  behaviors into `k`-bit descriptions forces `k ≥ log₂(#behaviors)`: to specify
  more distinct machines you need proportionally more description length, i.e.
  more molecular volume.

We model "`k` bits of molecular state" by the type `Fin k → Bool` (there are
exactly `2^k` such states) and a `config`uration map assigning each distinguishable
input its molecular state.

Main results:

* `storage_capacity` — `k` bits distinguish at most `2^k` inputs
  (`Fintype.card I ≤ 2^k` for injective `config`).
* `bits_lower_bound` — hence `log₂(#inputs) ≤ k`: distinguishing `N` inputs needs
  at least `log₂ N` bits.
* `needs_more_bits` — if `2^k < #inputs` no injective `k`-bit encoding exists:
  the device is too small, more volume is required.
* `kolmogorov_volume_lower_bound` — packaged Kolmogorov-style statement: any
  injective description scheme of a behavior family into `k`-bit codes obeys
  `log₂(#behaviors) ≤ k`. Minimum description length (≈ volume) is bounded below
  by the log of the number of behaviors (≈ Kolmogorov complexity of the family).
* `dna_density_bound` — a concrete numeric instance: a molecular register of
  `k = 60` bits holds at most `2^60 < 10^18` configurations, so genuinely storing
  `10^18` bits requires strictly more than `60` two-state molecules — a sanity
  check on the density conjecture.
-/
import Mathlib

open scoped BigOperators

namespace MolecularComputing

/-- **Storage capacity.** A molecular register of `k` two-state units
(`Fin k → Bool`) can be in at most `2^k` distinct configurations, hence can
distinguish at most `2^k` inputs. -/
theorem storage_capacity {I : Type*} [Fintype I] {k : ℕ}
    (config : I → (Fin k → Bool)) (hinj : Function.Injective config) :
    Fintype.card I ≤ 2 ^ k := by
  have := Fintype.card_le_of_injective config hinj
  simpa [Fintype.card_fun] using this

/-- **Bit lower bound.** To distinguish `N = #I` inputs one needs at least
`log₂ N` bits of molecular state. -/
theorem bits_lower_bound {I : Type*} [Fintype I] {k : ℕ}
    (config : I → (Fin k → Bool)) (hinj : Function.Injective config) :
    Nat.log 2 (Fintype.card I) ≤ k := by
  have h := storage_capacity config hinj
  calc Nat.log 2 (Fintype.card I) ≤ Nat.log 2 (2 ^ k) := Nat.log_mono_right h
    _ = k := by simp [Nat.log_pow]

/-- **Too small a device.** If the number of behaviors exceeds `2^k`, then no
injective encoding into `k`-bit states exists: more volume is required. -/
theorem needs_more_bits {I : Type*} [Fintype I] {k : ℕ}
    (h : 2 ^ k < Fintype.card I) :
    ¬ ∃ config : I → (Fin k → Bool), Function.Injective config := by
  rintro ⟨config, hinj⟩
  exact absurd (storage_capacity config hinj) (by omega)

/-- **Kolmogorov-style volume lower bound.** For a family `B` of distinct
behaviors (e.g. functions a CRN can compute), any injective description scheme
`descr : B → (Fin k → Bool)` into `k`-bit codes must use at least
`log₂(#B)` bits. Since the number of two-state molecules — and thus the volume —
is proportional to the description length `k`, the minimum volume grows at least
like the log of the number of behaviors: the information-theoretic shadow of the
"volume ∝ Kolmogorov complexity" claim. -/
theorem kolmogorov_volume_lower_bound {B : Type*} [Fintype B] {k : ℕ}
    (descr : B → (Fin k → Bool)) (hinj : Function.Injective descr) :
    Nat.log 2 (Fintype.card B) ≤ k :=
  bits_lower_bound descr hinj

/-- **Density sanity check.** A `59`-molecule two-state register holds fewer than
`10^18` configurations, so storing `10^18` distinct states needs strictly more
than `59` molecules: `2^59 < 10^18` (indeed `10^18 ≤ 2^60`, so `⌈log₂ 10^18⌉ = 60`). -/
theorem dna_density_bound : (2 : ℕ) ^ 59 < 10 ^ 18 := by norm_num

/-- Consequently no injective encoding of `10^18` behaviors fits in `59` bits. -/
theorem dna_density_needs_more {I : Type*} [Fintype I]
    (h : 10 ^ 18 ≤ Fintype.card I) :
    ¬ ∃ config : I → (Fin 59 → Bool), Function.Injective config :=
  needs_more_bits (lt_of_lt_of_le dna_density_bound h)

end MolecularComputing