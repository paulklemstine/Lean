import Catalog.Shared.SidonSetsErdosTuran

/-!
# Sidon sets III: the cyclic Erdős–Turán sandwich

Third cycle of the Sidon-set research thread.  Cycle 1 built the Erdős–Turán set in
`ℕ` and the sandwich `√(N/8) < maxSidonCard N ≤ √(2N) + 1`; cycle 2 established the
counting characterisation, extremal rigidity, and a Reiman double count.  Here we lift
the whole theory from the *interval* `{0, …, N-1}` to the *cyclic group* `ZMod N`, where
wrap-around could a priori destroy the uniqueness of representations.

## Main results

* `ErdosTuran.shift_absurd` — the shifted digit identity `k₃ + k₄ = k₁ + k₂ + p` is
  incompatible with the Erdős–Turán quadratic-residue identity; this is the extra input
  needed beyond cycle 1.
* `ErdosTuran.etSet_isSidon_mod` — **the Erdős–Turán set is Sidon modulo `2p²`**, a
  strictly stronger statement than `etSet_isSidon`: the sums live in `[0, 4p²)`, so a
  congruence modulo `2p²` is either a genuine equality (handled by cycle 1) or a shift
  by exactly `2p²` (excluded by `shift_absurd`).
* `ErdosTuran.etSetZMod_isSidon`, `ErdosTuran.etSetZMod_card` — hence `ZMod (2p²)`
  contains a Sidon set of size `p`.
* `ErdosTuran.zmod_sidon_sandwich_prime` — in `ZMod (2p²)`, of order `N = 2p²`, the
  largest Sidon set has size between `√(N/2)` and `√N + 1`: a factor `√2`.
* `isSidon_image_natCast` — **transfer principle**: a Sidon subset of `{0, …, n-1}`
  remains Sidon in `ZMod N` for every `N ≥ 2n`.
* `zmod_sidon_sandwich` — **for every `N ≥ 64`**, the largest Sidon set in `ZMod N` has
  size strictly between `√(N/16)` and `√N + 1`; so `ZMod N` also realises `Θ(√N)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Cycle 2 showed the Sidon property is a single injectivity.
  The bold question for cycle 3: does that injectivity survive *quotienting*?  Three
  conjectures were tabled.
  (S1) The Erdős–Turán set is Sidon not just in `ℤ` but already in `ℤ/2p²ℤ` — the
       tightest cyclic modulus for which its elements are distinct.
  (S2) Sidon-ness in `ℤ/Nℤ` is *not* automatic from Sidon-ness in an interval; a
       modulus barely larger than the diameter should fail.
  (S3) Every cyclic group of order `N` contains a Sidon set of size `Θ(√N)`.
Experiment (Experimenter): (S1) was proved.  Direct evaluation first *found* the
  phenomenon: `etSet p` is Sidon mod `2p²` for `p = 3, 5, 7, 11, 13`, but Sidon mod
  `2p² + 1` fails for all of them, so (S2) holds computationally and (S1) is sharp in
  the modulus.  The formal proof isolates the only obstruction: two sums of pairs both
  lie in `[0, 4p²)`, so their difference is `0` or `±2p²`; the shifted case forces
  `k₃ + k₄ = k₁ + k₂ + p`, which `shift_absurd` refutes because `etKey` already forces
  `k₃ + k₄ = k₁ + k₂` exactly.  (S3) was proved via a transfer principle plus
  Bertrand's postulate.
Analysis (Analyst): The reason wrap-around is harmless at modulus exactly `2p²` is
  arithmetic, not accidental: `2p² = 2p · p`, so a shift by the modulus is a shift of
  the *high* `2p`-adic digit by exactly `p`, and the Vieta rigidity of cycle 1 pins the
  high digit sum on the nose.  At modulus `2p² + 1` the shift is no longer a clean digit
  shift, and the construction breaks — exactly as observed numerically.
Critique (Critic): `etSet_isSidon_mod` is not vacuous: `etSetZMod p` has `p` distinct
  elements (`etSetZMod_card`), so there are genuinely `C(p+1,2)` distinct pairwise sums
  being separated.  The general result `zmod_sidon_sandwich` is guarded by `N ≥ 64`,
  needed so that `Nat.sqrt (N / 16) ≥ 2` and Bertrand's window contains an odd prime;
  the bound is not claimed below that.  No step uses `decide` or `native_decide`.
Synthesis (PI): the additive-combinatorial rigidity of cycle 1 is strong enough to
  survive the quotient by `2p²`; the interval theory and the cyclic theory therefore
  agree to within an absolute constant, and both are `Θ(√N)`.
-/

open Finset


namespace ErdosTuran

variable {p : ℕ}

/-- A shifted digit identity is impossible: `etKey` forces `k₁ + k₂ = k₃ + k₄`, which
contradicts a shift by `p`. -/
theorem shift_absurd (hp : p.Prime) (hodd : p ≠ 2) {k₁ k₂ k₃ k₄ : ℕ}
    (h₁ : k₁ < p) (h₂ : k₂ < p) (h₃ : k₃ < p) (h₄ : k₄ < p)
    (hS : k₃ + k₄ = k₁ + k₂ + p)
    (hr : k₁ ^ 2 % p + k₂ ^ 2 % p = k₃ ^ 2 % p + k₄ ^ 2 % p) : False := by
  have hsZ : ((k₁ : ZMod p)) + (k₂ : ZMod p) = (k₃ : ZMod p) + (k₄ : ZMod p) := by
    have h := congrArg (fun n : ℕ => (n : ZMod p)) hS
    push_cast at h
    rw [ZMod.natCast_self] at h
    rw [h]; ring
  rcases etKey hp hodd h₁ h₂ h₃ h₄ hsZ hr with ⟨e1, e2⟩ | ⟨e1, e2⟩ <;>
    · subst e1; subst e2; omega

/-- **The Erdős–Turán set is Sidon modulo `2p²`.**  This is strictly stronger than
`etSet_isSidon`: the uniqueness of representations survives the wrap-around of the
cyclic group `ℤ/2p²ℤ`. -/
theorem etSet_isSidon_mod (hp : p.Prime) (hodd : p ≠ 2) :
    ∀ u ∈ etSet p, ∀ v ∈ etSet p, ∀ w ∈ etSet p, ∀ x ∈ etSet p,
      (u + v) % (2 * p ^ 2) = (w + x) % (2 * p ^ 2) →
      (u = w ∧ v = x) ∨ (u = x ∧ v = w) := by
  have hp0 : 0 < p := hp.pos
  have hM : 0 < 2 * p ^ 2 := by positivity
  intro u hu v hv w hw x hx hcong
  obtain ⟨k₁, hk₁, rfl⟩ := mem_etSet_iff.mp hu
  obtain ⟨k₂, hk₂, rfl⟩ := mem_etSet_iff.mp hv
  obtain ⟨k₃, hk₃, rfl⟩ := mem_etSet_iff.mp hw
  obtain ⟨k₄, hk₄, rfl⟩ := mem_etSet_iff.mp hx
  have hmod : ∀ k : ℕ, k ^ 2 % p < p := fun k => Nat.mod_lt _ hp0
  -- the two sums, in `2p`-adic digit form
  have hA : etMap p k₁ + etMap p k₂ = 2 * p * (k₁ + k₂) + (k₁ ^ 2 % p + k₂ ^ 2 % p) :=
    etMap_add k₁ k₂
  have hB : etMap p k₃ + etMap p k₄ = 2 * p * (k₃ + k₄) + (k₃ ^ 2 % p + k₄ ^ 2 % p) :=
    etMap_add k₃ k₄
  -- both sums are `< 4p²`
  have hAlt : etMap p k₁ + etMap p k₂ < 4 * p ^ 2 := by
    have := etMap_lt hp0 hk₁; have := etMap_lt hp0 hk₂; omega
  have hBlt : etMap p k₃ + etMap p k₄ < 4 * p ^ 2 := by
    have := etMap_lt hp0 hk₃; have := etMap_lt hp0 hk₄; omega
  -- a congruence between two numbers `< 2M` is an equality or a shift by `M`
  have hme : (etMap p k₁ + etMap p k₂) ≡ (etMap p k₃ + etMap p k₄) [MOD 2 * p ^ 2] := hcong
  obtain ⟨c, hc⟩ := Nat.ModEq.dvd hme
  have hX2 : etMap p k₁ + etMap p k₂ < 2 * (2 * p ^ 2) := by linarith
  have hY2 : etMap p k₃ + etMap p k₄ < 2 * (2 * p ^ 2) := by linarith
  have hXz : ((etMap p k₁ + etMap p k₂ : ℕ) : ℤ) < 2 * ((2 * p ^ 2 : ℕ) : ℤ) := by
    exact_mod_cast hX2
  have hYz : ((etMap p k₃ + etMap p k₄ : ℕ) : ℤ) < 2 * ((2 * p ^ 2 : ℕ) : ℤ) := by
    exact_mod_cast hY2
  have hXz0 : (0 : ℤ) ≤ ((etMap p k₁ + etMap p k₂ : ℕ) : ℤ) := Int.natCast_nonneg _
  have hYz0 : (0 : ℤ) ≤ ((etMap p k₃ + etMap p k₄ : ℕ) : ℤ) := Int.natCast_nonneg _
  have hMz : (0 : ℤ) < ((2 * p ^ 2 : ℕ) : ℤ) := by exact_mod_cast hM
  have hclt : c < 2 := by
    by_contra hcon
    push_neg at hcon
    have := mul_le_mul_of_nonneg_left hcon hMz.le
    linarith
  have hcgt : -2 < c := by
    by_contra hcon
    push_neg at hcon
    have := mul_le_mul_of_nonneg_left hcon hMz.le
    linarith
  have hcases : c = -1 ∨ c = 0 ∨ c = 1 := by omega
  rcases hcases with rfl | rfl | rfl
  · -- `B + M = A`
    exfalso
    have heq : etMap p k₁ + etMap p k₂ = etMap p k₃ + etMap p k₄ + 2 * p ^ 2 := by
      have : ((etMap p k₃ + etMap p k₄ : ℕ) : ℤ) - ((etMap p k₁ + etMap p k₂ : ℕ) : ℤ)
          = -(2 * (p : ℤ) ^ 2) := by push_cast at hc ⊢; linarith
      have h' : ((etMap p k₁ + etMap p k₂ : ℕ) : ℤ)
          = ((etMap p k₃ + etMap p k₄ + 2 * p ^ 2 : ℕ) : ℤ) := by push_cast at this ⊢; linarith
      exact_mod_cast h'
    rw [hA, hB] at heq
    have hshift : 2 * p * (k₁ + k₂) + (k₁ ^ 2 % p + k₂ ^ 2 % p)
        = 2 * p * (k₃ + k₄ + p) + (k₃ ^ 2 % p + k₄ ^ 2 % p) := by
      have : 2 * p * (k₃ + k₄ + p) = 2 * p * (k₃ + k₄) + 2 * p ^ 2 := by ring
      omega
    obtain ⟨hS, hr⟩ :=
      base_digits_unique (m := 2 * p) (by omega)
        (by have := hmod k₁; have := hmod k₂; omega)
        (by have := hmod k₃; have := hmod k₄; omega) hshift
    exact shift_absurd hp hodd hk₃ hk₄ hk₁ hk₂ (by omega) hr.symm
  · -- genuine equality: fall back to the integer Sidon property
    have heq : etMap p k₁ + etMap p k₂ = etMap p k₃ + etMap p k₄ := by
      have : ((etMap p k₃ + etMap p k₄ : ℕ) : ℤ) - ((etMap p k₁ + etMap p k₂ : ℕ) : ℤ) = 0 := by
        simpa using hc
      have h' : ((etMap p k₁ + etMap p k₂ : ℕ) : ℤ) = ((etMap p k₃ + etMap p k₄ : ℕ) : ℤ) := by
        linarith
      exact_mod_cast h'
    exact etSet_isSidon hp hodd _ hu _ hv _ hw _ hx heq
  · -- `A + M = B`
    exfalso
    have heq : etMap p k₃ + etMap p k₄ = etMap p k₁ + etMap p k₂ + 2 * p ^ 2 := by
      have h' : ((etMap p k₃ + etMap p k₄ : ℕ) : ℤ)
          = ((etMap p k₁ + etMap p k₂ + 2 * p ^ 2 : ℕ) : ℤ) := by push_cast at hc ⊢; linarith
      exact_mod_cast h'
    rw [hA, hB] at heq
    have hshift : 2 * p * (k₃ + k₄) + (k₃ ^ 2 % p + k₄ ^ 2 % p)
        = 2 * p * (k₁ + k₂ + p) + (k₁ ^ 2 % p + k₂ ^ 2 % p) := by
      have : 2 * p * (k₁ + k₂ + p) = 2 * p * (k₁ + k₂) + 2 * p ^ 2 := by ring
      omega
    obtain ⟨hS, hr⟩ :=
      base_digits_unique (m := 2 * p) (by omega)
        (by have := hmod k₃; have := hmod k₄; omega)
        (by have := hmod k₁; have := hmod k₂; omega) hshift
    exact shift_absurd hp hodd hk₁ hk₂ hk₃ hk₄ (by omega) hr.symm

end ErdosTuran

namespace ErdosTuran

variable {p : ℕ}

/-- The Erdős–Turán set viewed inside the **cyclic group** `ZMod (2p²)`. -/
def etSetZMod (p : ℕ) : Finset (ZMod (2 * p ^ 2)) :=
  (etSet p).image (fun n : ℕ => (n : ZMod (2 * p ^ 2)))

theorem natCast_injOn_etSet (hp0 : 0 < p) :
    Set.InjOn (fun n : ℕ => (n : ZMod (2 * p ^ 2))) (etSet p : Set ℕ) := by
  intro u hu v hv h
  have hu' : u < 2 * p ^ 2 := Finset.mem_range.mp (etSet_subset hp0 (by simpa using hu))
  have hv' : v < 2 * p ^ 2 := Finset.mem_range.mp (etSet_subset hp0 (by simpa using hv))
  have := (ZMod.natCast_eq_natCast_iff' u v (2 * p ^ 2)).mp h
  rwa [Nat.mod_eq_of_lt hu', Nat.mod_eq_of_lt hv'] at this

theorem etSetZMod_card (hp0 : 0 < p) : #(etSetZMod p) = p := by
  rw [etSetZMod, Finset.card_image_of_injOn (natCast_injOn_etSet hp0), etSet_card hp0]

/-- **A Sidon set in a cyclic group.**  For an odd prime `p`, the reduction of the
Erdős–Turán set modulo `2p²` is a Sidon set of size `p` in `ZMod (2p²)`. -/
theorem etSetZMod_isSidon (hp : p.Prime) (hodd : p ≠ 2) : IsSidon (etSetZMod p) := by
  intro a ha b hb c hc d hd hsum
  simp only [etSetZMod, Finset.mem_image] at ha hb hc hd
  obtain ⟨u, hu, rfl⟩ := ha
  obtain ⟨v, hv, rfl⟩ := hb
  obtain ⟨w, hw, rfl⟩ := hc
  obtain ⟨x, hx, rfl⟩ := hd
  have hcast : ((u + v : ℕ) : ZMod (2 * p ^ 2)) = ((w + x : ℕ) : ZMod (2 * p ^ 2)) := by
    push_cast
    exact hsum
  have hmod : (u + v) % (2 * p ^ 2) = (w + x) % (2 * p ^ 2) :=
    (ZMod.natCast_eq_natCast_iff' _ _ _).mp hcast
  rcases etSet_isSidon_mod hp hodd u hu v hv w hw x hx hmod with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨by rw [h1], by rw [h2]⟩
  · exact Or.inr ⟨by rw [h1], by rw [h2]⟩

/-- **The cyclic Erdős–Turán sandwich.**  In the cyclic group `ZMod (2p²)` of order
`N = 2p²`, for an odd prime `p`, there is a Sidon set of size `p = √(N/2)`, and no Sidon
set has more than `√N + 1 ≈ √2 · p` elements.  The two bounds differ by a factor `√2`. -/
theorem zmod_sidon_sandwich_prime (hp : p.Prime) (hodd : p ≠ 2) :
    (∃ A : Finset (ZMod (2 * p ^ 2)), IsSidon A ∧ #A = p) ∧
      (∀ A : Finset (ZMod (2 * p ^ 2)), IsSidon A → #A ≤ Nat.sqrt (2 * p ^ 2) + 1) := by
  have hp0 : 0 < p := hp.pos
  haveI : NeZero (2 * p ^ 2) := ⟨by positivity⟩
  refine ⟨⟨etSetZMod p, etSetZMod_isSidon hp hodd, etSetZMod_card hp0⟩, ?_⟩
  intro A hA
  have h := hA.card_le_sqrt
  rwa [ZMod.card] at h

end ErdosTuran

/-! ## Transfer of Sidon sets from `ℕ` to arbitrary cyclic groups -/

/-- **Transfer principle.**  A Sidon subset of `{0, …, n-1}` stays Sidon after reduction
modulo any `N ≥ 2n`: no wrap-around can create a new coincidence of sums. -/
theorem isSidon_image_natCast {A : Finset ℕ} {n N : ℕ} (hA : IsSidon A)
    (hsub : A ⊆ Finset.range n) (hN : 2 * n ≤ N) :
    IsSidon (A.image (fun a : ℕ => (a : ZMod N))) := by
  intro a ha b hb c hc d hd hsum
  simp only [Finset.mem_image] at ha hb hc hd
  obtain ⟨u, hu, rfl⟩ := ha
  obtain ⟨v, hv, rfl⟩ := hb
  obtain ⟨w, hw, rfl⟩ := hc
  obtain ⟨x, hx, rfl⟩ := hd
  have hu' : u < n := Finset.mem_range.mp (hsub hu)
  have hv' : v < n := Finset.mem_range.mp (hsub hv)
  have hw' : w < n := Finset.mem_range.mp (hsub hw)
  have hx' : x < n := Finset.mem_range.mp (hsub hx)
  have hcast : ((u + v : ℕ) : ZMod N) = ((w + x : ℕ) : ZMod N) := by push_cast; exact hsum
  have hmod : (u + v) % N = (w + x) % N := (ZMod.natCast_eq_natCast_iff' _ _ _).mp hcast
  rw [Nat.mod_eq_of_lt (by omega), Nat.mod_eq_of_lt (by omega)] at hmod
  rcases hA u hu v hv w hw x hx hmod with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨by rw [h1], by rw [h2]⟩
  · exact Or.inr ⟨by rw [h1], by rw [h2]⟩

theorem card_image_natCast {A : Finset ℕ} {n N : ℕ} (hsub : A ⊆ Finset.range n) (hn : n ≤ N) :
    #(A.image (fun a : ℕ => (a : ZMod N))) = #A := by
  refine Finset.card_image_of_injOn ?_
  intro u hu v hv h
  have hu' : u < n := Finset.mem_range.mp (hsub (by simpa using hu))
  have hv' : v < n := Finset.mem_range.mp (hsub (by simpa using hv))
  have := (ZMod.natCast_eq_natCast_iff' u v N).mp h
  rwa [Nat.mod_eq_of_lt (by omega), Nat.mod_eq_of_lt (by omega)] at this

/-- **Large Sidon sets exist in every cyclic group.**  For `N ≥ 64` the group `ZMod N`
contains a Sidon set of size `> √(N/16)`.  Bertrand's postulate supplies the prime. -/
theorem exists_large_sidon_zmod {N : ℕ} (hN : 64 ≤ N) :
    ∃ A : Finset (ZMod N), IsSidon A ∧ Nat.sqrt (N / 16) < #A := by
  set m := Nat.sqrt (N / 16) with hm
  have hm2 : 2 ≤ m := by rw [hm, Nat.le_sqrt]; omega
  obtain ⟨p, hp, hmp, hp2m⟩ := Nat.bertrand m (by omega)
  have hodd : p ≠ 2 := by omega
  have hmm : m * m ≤ N / 16 := Nat.sqrt_le (N / 16)
  have h16 : 16 * (m * m) ≤ N := by
    have := Nat.div_mul_le_self N 16
    omega
  have hfit : 2 * (2 * p ^ 2) ≤ N := by nlinarith
  refine ⟨(ErdosTuran.etSet p).image (fun a : ℕ => (a : ZMod N)), ?_, ?_⟩
  · exact isSidon_image_natCast (ErdosTuran.etSet_isSidon hp hodd)
      (ErdosTuran.etSet_subset hp.pos) hfit
  · rw [card_image_natCast (ErdosTuran.etSet_subset hp.pos) (by omega),
      ErdosTuran.etSet_card hp.pos]
    exact hmp

/-- **The cyclic sandwich: the largest Sidon set in `ZMod N` has size `Θ(√N)`.**
For every `N ≥ 64` there is a Sidon set of size `> √(N/16)`, and every Sidon set has size
`≤ √N + 1`. -/
theorem zmod_sidon_sandwich {N : ℕ} (hN : 64 ≤ N) :
    (∃ A : Finset (ZMod N), IsSidon A ∧ Nat.sqrt (N / 16) < #A) ∧
      (∀ A : Finset (ZMod N), IsSidon A → #A ≤ Nat.sqrt N + 1) := by
  haveI : NeZero N := ⟨by omega⟩
  refine ⟨exists_large_sidon_zmod hN, ?_⟩
  intro A hA
  have h := hA.card_le_sqrt
  rwa [ZMod.card] at h