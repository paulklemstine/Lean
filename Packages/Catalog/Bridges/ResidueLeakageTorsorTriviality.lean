/-
# The consistent factor-fingerprint set is a trivial torsor (conjecture C5, closed)

Eighth file of the residue-leakage thread.  The previous files show that the QR
fingerprint prunes nothing (`dirichlet_no_pruning`), that all `2^K` patterns
occur (`qrFingerprint_pattern_surjective`), and that consistency of a pair of
primes with the observation is *exactly* the symmetric relation
`(a|q) = (a|N₀)·(a|p)` (`consistent_iff_product_constraint`).

Conjecture C5 of `FUTURE_DIRECTIONS.md` asked for the structural reformulation:
the "factorisation fibre"

`Φ(N₀) = { (F_A(p), F_A(q)) : p, q prime, F_A(p·q) = F_A(N₀) }`

should be a *trivial torsor* under the anti-diagonal
`Δ⁻ = { (w, w) : w ∈ {±1}^K }`, and this triviality should be equivalent to the
no-pruning statement.  This file proves it:

* `consistentPairs_eq` — the fibre is precisely the graph of the translation
  `u ↦ F_A(N₀) · u`, i.e. a coset of `Δ⁻` in `{±1}^K × {±1}^K`;
* `consistentPairs_simply_transitive` — `Δ⁻` acts *simply transitively* on the
  fibre (existence **and** uniqueness of the connecting sign vector): the fibre
  has trivial monodromy, so it is a trivial `Δ⁻`-torsor;
* `consistentPairs_fst_eq` — the fibre projects **onto** all of `{±1}^K` in the
  first coordinate, which is the no-pruning theorem in torsor form;
* `consistentPairs_ncard` — the fibre has exactly `2^K` elements, i.e. the
  residue channel leaves exactly the full `K` free bits of `F_A(p)`.

Everything is proved for an arbitrary duplicate-free list `A` of probe primes.
-/

import Mathlib
import Bridges.ResidueLeakageDirichletNoPruning
import Bridges.ResidueLeakagePatternSurjectivity
import Bridges.ResidueChannelCosetStructure
import Bridges.ResidueLeakageCounting

namespace Bridges.ResidueLeakage

/-! ## Pointwise multiplication of sign vectors -/

/-- Pointwise product of two sign vectors; the group law of `{±1}^K`. -/
def signMul (u v : List ℤ) : List ℤ := List.zipWith (· * ·) u v

theorem signMul_map (A : List ℕ) (f g : ℕ → ℤ) :
    signMul (A.map f) (A.map g) = A.map fun a => f a * g a := by
  induction A with
  | nil => rfl
  | cons a t ih =>
      simp only [signMul, List.map_cons, List.zipWith_cons_cons] at *
      rw [ih]

/-- Membership in `signVectors` for a list presented as a map. -/
theorem map_mem_signVectors {A : List ℕ} {f : ℕ → ℤ}
    (hf : ∀ a ∈ A, f a = 1 ∨ f a = -1) : A.map f ∈ signVectors A.length := by
  refine ⟨by simp, ?_⟩
  intro x hx
  obtain ⟨a, ha, rfl⟩ := List.mem_map.1 hx
  exact hf a ha

/-! ## Bookkeeping: symbols of a prime outside the probe set -/

/-- A prime all of whose probe symbols are nonzero is not itself a probe. -/
theorem not_mem_of_jacobi_ne_zero {A : List ℕ} {x : ℕ} (hx : x.Prime)
    (h : ∀ a ∈ A, jacobiSym (a : ℤ) x ≠ 0) : x ∉ A := by
  intro hxA
  haveI : NeZero x := ⟨hx.ne_zero⟩
  refine h x hxA ?_
  rw [jacobiSym.eq_zero_iff_not_coprime]
  simp [hx.one_lt.ne']

/-- The observed fingerprint has `±1` entries as soon as the target is coprime
to the probes. -/
theorem jacobiSym_target_eq_one_or_neg_one {A : List ℕ} {N₀ : ℕ}
    (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) {a : ℕ} (ha : a ∈ A) :
    jacobiSym (a : ℤ) N₀ = 1 ∨ jacobiSym (a : ℤ) N₀ = -1 := by
  refine jacobiSym.eq_one_or_neg_one ?_
  simpa [Int.gcd_natCast_natCast, Nat.Coprime, Nat.gcd_comm] using (hNA a ha)

/-! ## The factorisation fibre -/

/-- The **factorisation fibre** of the observation `F_A(N₀)`: all pairs of
fingerprints `(F_A(p), F_A(q))` of primes `p, q` outside the probe set whose
product has the observed fingerprint. -/
def consistentPairs (A : List ℕ) (N₀ : ℕ) : Set (List ℤ × List ℤ) :=
  {uv | ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ∉ A ∧ q ∉ A ∧
      qrFingerprint A p = uv.1 ∧ qrFingerprint A q = uv.2 ∧
      qrFingerprint A (p * q) = qrFingerprint A N₀}

/-- **The fibre is a coset of the anti-diagonal.**  A pair of sign vectors is
realised by a consistent pair of primes exactly when the second coordinate is
the pointwise product of the observation with the first.  In particular the
first coordinate is completely free: the channel carries no information about
the individual factor. -/
theorem consistentPairs_eq {A : List ℕ} (hA : ∀ a ∈ A, a.Prime) (hnd : A.Nodup)
    {N₀ : ℕ} (hN₀ : Odd N₀) (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) :
    consistentPairs A N₀ =
      {uv : List ℤ × List ℤ | uv.1 ∈ signVectors A.length ∧
        uv.2 = signMul (qrFingerprint A N₀) uv.1} := by
  ext ⟨u, v⟩
  constructor
  · rintro ⟨p, q, hp, hq, hpA, hqA, rfl, rfl, hcons⟩
    have hu : qrFingerprint A p ∈ signVectors A.length := by
      have : qrFingerprint A p ∈
          {v : List ℤ | ∃ q : ℕ, q.Prime ∧ q ∉ A ∧ qrFingerprint A q = v} :=
        ⟨p, hp, hpA, rfl⟩
      rwa [qrFingerprint_range_eq hA hnd] at this
    refine ⟨hu, ?_⟩
    have hpne : ∀ a ∈ A, a ≠ p := fun a ha hap => hpA (hap ▸ ha)
    have hrel := (consistent_iff_product_constraint hA hp hq hpne).1 hcons
    rw [show qrFingerprint A N₀ = A.map (fun a : ℕ => jacobiSym (a : ℤ) N₀) from rfl,
      show qrFingerprint A p = A.map (fun a : ℕ => jacobiSym (a : ℤ) p) from rfl,
      signMul_map]
    exact List.map_congr_left hrel
  · rintro ⟨hu, hv⟩
    dsimp only at hu hv
    subst hv
    obtain ⟨hlen, hentries⟩ := hu
    obtain ⟨ε, hε⟩ := exists_map_eq_of_nodup A hnd u hlen
    have hεA : ∀ a ∈ A, ε a = 1 ∨ ε a = -1 := fun a ha =>
      hentries (ε a) (hε ▸ List.mem_map_of_mem ha)
    obtain ⟨p, q, hp, hq, hpf, hcons⟩ :=
      residue_channel_full_coset hA hnd hN₀ hNA hεA
    have hpsym : ∀ a ∈ A, jacobiSym (a : ℤ) p = ε a := fun a ha =>
      List.map_inj_left.1 hpf a ha
    have hpA : p ∉ A := by
      refine not_mem_of_jacobi_ne_zero hp fun a ha => ?_
      rw [hpsym a ha]
      rcases hεA a ha with h | h <;> rw [h] <;> norm_num
    have hpne : ∀ a ∈ A, a ≠ p := fun a ha hap => hpA (hap ▸ ha)
    have hrel := (consistent_iff_product_constraint hA hp hq hpne).1 hcons
    have hqA : q ∉ A := by
      refine not_mem_of_jacobi_ne_zero hq fun a ha => ?_
      rw [hrel a ha]
      rcases jacobiSym_target_eq_one_or_neg_one hNA ha with h | h <;>
        rcases hεA a ha with h' | h' <;>
        rw [h, hpsym a ha, h'] <;> norm_num
    refine ⟨p, q, hp, hq, hpA, hqA, by rw [hpf, hε], ?_, hcons⟩
    rw [show qrFingerprint A q = A.map (fun a : ℕ => jacobiSym (a : ℤ) q) from rfl,
      show qrFingerprint A N₀ = A.map (fun a : ℕ => jacobiSym (a : ℤ) N₀) from rfl,
      ← hε, signMul_map]
    exact List.map_congr_left fun a ha => by rw [hrel a ha, hpsym a ha]

/-! ## Trivial monodromy: the anti-diagonal acts simply transitively -/

/-- **Simple transitivity of the anti-diagonal `Δ⁻`.**  Any two consistent
factor-fingerprint pairs differ by a *unique* sign vector `w`, acting
simultaneously on both coordinates.  Thus the factorisation fibre is a trivial
`Δ⁻`-torsor: it has no monodromy, which is the structural form of the
no-pruning theorem. -/
theorem consistentPairs_simply_transitive {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (hnd : A.Nodup) {N₀ : ℕ} (hN₀ : Odd N₀) (hNA : ∀ a ∈ A, Nat.Coprime N₀ a)
    {x y : List ℤ × List ℤ} (hx : x ∈ consistentPairs A N₀)
    (hy : y ∈ consistentPairs A N₀) :
    ∃! w : List ℤ, w ∈ signVectors A.length ∧
      y.1 = signMul w x.1 ∧ y.2 = signMul w x.2 := by
  rw [consistentPairs_eq hA hnd hN₀ hNA] at hx hy
  obtain ⟨⟨hxlen, hxent⟩, hx2⟩ := hx
  obtain ⟨⟨hylen, hyent⟩, hy2⟩ := hy
  obtain ⟨ε, hε⟩ := exists_map_eq_of_nodup A hnd x.1 hxlen
  obtain ⟨δ, hδ⟩ := exists_map_eq_of_nodup A hnd y.1 hylen
  have hεA : ∀ a ∈ A, ε a = 1 ∨ ε a = -1 := fun a ha =>
    hxent (ε a) (hε ▸ List.mem_map_of_mem ha)
  have hδA : ∀ a ∈ A, δ a = 1 ∨ δ a = -1 := fun a ha =>
    hyent (δ a) (hδ ▸ List.mem_map_of_mem ha)
  have hsq : ∀ a ∈ A, ε a * ε a = 1 := by
    intro a ha; rcases hεA a ha with h | h <;> rw [h] <;> norm_num
  refine ⟨A.map fun a => δ a * ε a, ⟨map_mem_signVectors ?_, ?_, ?_⟩, ?_⟩
  · intro a ha
    rcases hδA a ha with h | h <;> rcases hεA a ha with h' | h' <;>
      rw [h, h'] <;> norm_num
  · rw [← hε, ← hδ]
    simp only [signMul_map]
    exact (List.map_congr_left fun a ha => by
      rw [mul_assoc, hsq a ha, mul_one]).symm
  · rw [hx2, hy2, ← hε, ← hδ,
      show qrFingerprint A N₀ = A.map (fun a : ℕ => jacobiSym (a : ℤ) N₀) from rfl]
    simp only [signMul_map]
    refine List.map_congr_left fun a ha => ?_
    calc jacobiSym (a : ℤ) N₀ * δ a
        = δ a * (ε a * ε a) * jacobiSym (a : ℤ) N₀ := by rw [hsq a ha]; ring
      _ = δ a * ε a * (jacobiSym (a : ℤ) N₀ * ε a) := by ring
  · rintro w ⟨⟨hwlen, -⟩, hw1, -⟩
    obtain ⟨γ, hγ⟩ := exists_map_eq_of_nodup A hnd w hwlen
    rw [← hγ, ← hε, signMul_map] at hw1
    rw [← hδ] at hw1
    have hpt : ∀ a ∈ A, δ a = γ a * ε a := List.map_inj_left.1 hw1
    rw [← hγ]
    refine List.map_congr_left fun a ha => ?_
    rw [hpt a ha, mul_assoc, hsq a ha, mul_one]

/-! ## Torsor form of the no-pruning theorem, and the exact size of the fibre -/

/-- **No pruning, torsor form.**  The fibre projects onto *every* sign pattern
of the first factor: observing `F_A(N₀)` excludes no value of `F_A(p)`. -/
theorem consistentPairs_fst_eq {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (hnd : A.Nodup) {N₀ : ℕ} (hN₀ : Odd N₀) (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) :
    Prod.fst '' consistentPairs A N₀ = signVectors A.length := by
  rw [consistentPairs_eq hA hnd hN₀ hNA]
  ext u
  constructor
  · rintro ⟨⟨u', v'⟩, ⟨hu', -⟩, rfl⟩; exact hu'
  · intro hu
    exact ⟨(u, signMul (qrFingerprint A N₀) u), ⟨hu, rfl⟩, rfl⟩

/-- **The fibre has exactly `2^K` elements.**  Equivalently: the residue channel
leaves all `K` bits of the factor fingerprint free — the leakage about the
factorisation is exactly `0` bits, while the leakage about `N` is `K` bits
(`qrFingerprint_range_ncard`). -/
theorem consistentPairs_ncard {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (hnd : A.Nodup) {N₀ : ℕ} (hN₀ : Odd N₀) (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) :
    (consistentPairs A N₀).ncard = 2 ^ A.length := by
  have himg : consistentPairs A N₀ =
      (fun u => (u, signMul (qrFingerprint A N₀) u)) '' signVectors A.length := by
    rw [consistentPairs_eq hA hnd hN₀ hNA]
    ext ⟨u, v⟩
    constructor
    · rintro ⟨hu, hv⟩
      dsimp only at hu hv
      subst hv
      exact ⟨u, hu, rfl⟩
    · rintro ⟨u', hu', h⟩
      obtain ⟨rfl, rfl⟩ := Prod.mk.injEq .. ▸ h
      exact ⟨hu', rfl⟩
  have hinj : Function.Injective
      (fun u => (u, signMul (qrFingerprint A N₀) u)) := by
    intro a b hab
    simpa using congrArg Prod.fst hab
  rw [himg, Set.ncard_image_of_injective _ hinj, signVectors_ncard]

/-- Specialisation to the first `K` primes: the factorisation fibre of any odd
target coprime to the first `K` primes is a trivial torsor of size `2^K`. -/
theorem primeBasis_consistentPairs_ncard (K : ℕ) {N₀ : ℕ} (hN₀ : Odd N₀)
    (hNA : ∀ a ∈ primeBasis K, Nat.Coprime N₀ a) :
    (consistentPairs (primeBasis K) N₀).ncard = 2 ^ K := by
  have := consistentPairs_ncard (A := primeBasis K)
    (fun _ ha => primeBasis_prime ha) (primeBasis_nodup K) hN₀ hNA
  simpa using this

end Bridges.ResidueLeakage