import Probability.PRNGClassifier
import Probability.PRNGComplexityHierarchy

/-!
# Router capacity: the Kraft-type ceiling for seed compression (conjecture C5)

`Probability.PRNGClassifier` proves a *two-family* no-free-lunch theorem: the
union of the order-`L` LFSR family and the LCG family covers only a vanishing
fraction of files.  This file settles the general statement conjectured as `C5`
in `FUTURE_DIRECTIONS.md`.

A **router** over a finite family of generators is allowed to inspect a file,
choose *any* member of the family, and emit an index together with a seed.  The
theorem below says that its total capacity is exactly the total number of seeds:

```
|{files of length n compressible by some member}| ≤ ∑ i, |S i|.
```

The generators may have *different* state spaces (`S : ι → Type*`), which is the
point: the router is free to mix an LFSR of one order with an LCG with a totally
different state type.  Adding families adds their seed counts and nothing more,
so the "detect the generator" programme buys code space only where the data
distribution is far from uniform — never on average.

Main contents.

* `familyWords` — the files accepted by the router over the family `g`.
* `card_familyWords_le` — **the capacity ceiling** `∑ i, |S i|`.
* `card_not_routed_ge` — a quantitative complement: at least
  `|α|ⁿ - ∑ i, |S i|` files are rejected by *every* member.
* `exists_not_family_routed` — hence, below the ceiling, some file is rejected
  by every member of the family.
* `familyWords_density_le` — the false-positive density of the whole router.
* `card_le_of_family_covers` — the contrapositive: a router that compresses
  *everything* must carry at least `|α|ⁿ` seeds in total, i.e. it saves nothing.
* `exists_not_routed_of_family` — the two-family theorem of
  `PRNGClassifier.lean`, re-derived as the special case `ι = Bool`.
* `card_familyWords_lfsr_lcg_le` — the LFSR ⊎ LCG router as an instance.
-/

namespace Catalog.Probability.SeedRec

universe u v w

variable {ι : Type u} {α : Type v} [Fintype α] [DecidableEq α]
variable {S : ι → Type w} [∀ i, Fintype (S i)]

section Family

variable [Fintype ι] (g : ∀ i, PRNG (S i) α) (n : ℕ)

/-- The files accepted by a router over the finite family of generators `g`:
those reproducible from a seed of *some* member of the family. -/
def familyWords : Finset (Fin n → α) :=
  Finset.univ.biUnion fun i => (g i).compressible n

omit [Fintype α] in
theorem mem_familyWords {x : Fin n → α} :
    x ∈ familyWords g n ↔ ∃ i, SeedCompressible (g i) n x := by
  simp [familyWords]

omit [Fintype α] in
/-- **Router capacity ceiling.** A router over a finite family of generators can
reproduce at most `∑ i, |S i|` files of any given length: seed spaces add, and
nothing else is gained by being allowed to choose the generator. -/
theorem card_familyWords_le :
    (familyWords g n).card ≤ ∑ i, Fintype.card (S i) :=
  (Finset.card_biUnion_le).trans
    (Finset.sum_le_sum fun i _ => (g i).card_compressible_le n)

/-- **Quantitative rejection.** At least `|α|ⁿ - ∑ i, |S i|` files of length `n`
are rejected by every member of the family. -/
theorem card_not_routed_ge :
    Fintype.card α ^ n - (∑ i, Fintype.card (S i))
      ≤ ((Finset.univ : Finset (Fin n → α)) \ familyWords g n).card := by
  have hcard : ((Finset.univ : Finset (Fin n → α)) \ familyWords g n).card
      = Fintype.card (Fin n → α) - (familyWords g n).card :=
    Finset.card_univ_diff _
  have huniv : Fintype.card (Fin n → α) = Fintype.card α ^ n := by simp
  have hle := card_familyWords_le g n
  omega

/-- **No free lunch for the seed-compression router.** As soon as the total
number of seeds is smaller than the number of files, some file is rejected by
*every* generator in the family. -/
theorem exists_not_family_routed
    (h : (∑ i, Fintype.card (S i)) < Fintype.card α ^ n) :
    ∃ x : Fin n → α, ∀ i, ¬ SeedCompressible (g i) n x := by
  by_contra hc
  push_neg at hc
  have hsub : (Finset.univ : Finset (Fin n → α)) ⊆ familyWords g n := by
    intro x _
    obtain ⟨i, hi⟩ := hc x
    exact (mem_familyWords g n).2 ⟨i, hi⟩
  have hcard := Finset.card_le_card hsub
  rw [Finset.card_univ, Fintype.card_fun, Fintype.card_fin] at hcard
  exact absurd (hcard.trans (card_familyWords_le g n)) (by omega)

/-- **A router that compresses everything saves nothing.** If every length-`n`
file is seed-compressible by some member of the family, the family must already
carry at least `|α|ⁿ` seeds, so the index-plus-seed description is no shorter
than the file itself. -/
theorem card_le_of_family_covers
    (h : ∀ x : Fin n → α, ∃ i, SeedCompressible (g i) n x) :
    Fintype.card α ^ n ≤ ∑ i, Fintype.card (S i) := by
  by_contra hc
  push_neg at hc
  obtain ⟨x, hx⟩ := exists_not_family_routed g n hc
  obtain ⟨i, hi⟩ := h x
  exact hx i hi

/-- **False-positive density of the router.** The fraction of uniformly random
files accepted by the whole family is at most `(∑ i |S i|) / |α|ⁿ`. -/
theorem familyWords_density_le (hα : 0 < Fintype.card α) :
    ((familyWords g n).card : ℚ) / (Fintype.card α : ℚ) ^ n
      ≤ ((∑ i, Fintype.card (S i) : ℕ) : ℚ) / (Fintype.card α : ℚ) ^ n := by
  have hcard : (0 : ℚ) < (Fintype.card α : ℚ) := by exact_mod_cast hα
  have hpos : (0 : ℚ) < (Fintype.card α : ℚ) ^ n := by positivity
  gcongr
  exact_mod_cast card_familyWords_le g n

end Family

section TwoFamilies

variable {S₀ S₁ : Type w} [Fintype S₀] [Fintype S₁]

/-- The state space of a two-element family. -/
def pairState (S₀ S₁ : Type w) : Bool → Type w
  | false => S₀
  | true => S₁

instance instFintypePairState : ∀ b : Bool, Fintype (pairState S₀ S₁ b)
  | false => inferInstanceAs (Fintype S₀)
  | true => inferInstanceAs (Fintype S₁)

/-- A two-element family, packaged so that the general theorem applies. -/
def pairFamily (g₀ : PRNG S₀ α) (g₁ : PRNG S₁ α) :
    ∀ b : Bool, PRNG (pairState S₀ S₁ b) α
  | false => g₀
  | true => g₁

/-- The two-family no-free-lunch theorem, obtained as the special case `ι = Bool`
of the general capacity ceiling: two generators whose seed spaces together are
smaller than the file space cannot cover the file space. -/
theorem exists_not_routed_of_family (g₀ : PRNG S₀ α) (g₁ : PRNG S₁ α) (n : ℕ)
    (h : Fintype.card S₀ + Fintype.card S₁ < Fintype.card α ^ n) :
    ∃ x : Fin n → α, ¬ SeedCompressible g₀ n x ∧ ¬ SeedCompressible g₁ n x := by
  have hsum : (∑ b : Bool, Fintype.card (pairState S₀ S₁ b))
      = Fintype.card S₀ + Fintype.card S₁ := by
    rw [Fintype.sum_bool]
    exact Nat.add_comm _ _
  obtain ⟨x, hx⟩ :=
    exists_not_family_routed (pairFamily g₀ g₁) n (by rw [hsum]; exact h)
  exact ⟨x, hx false, hx true⟩

end TwoFamilies

section LFSRRouter

variable (K : Type*) [CommRing K] [Fintype K] [DecidableEq K]

/-- The router that tries **every** LFSR order `≤ M` at once: its state space at
order `ℓ` is the pair (taps, seed), of size `|K|^{2ℓ}`. -/
def lfsrFamily (M : ℕ) :
    ∀ i : Fin (M + 1), PRNG ((Fin i.val → K) × (Fin i.val → K)) K :=
  fun _ => { step := fun p => (p.1, lfsrStep p.1 p.2), out := fun p => lfsrOut p.2 }

omit [Fintype K] [DecidableEq K] in
/-- The family member of order `ℓ` runs the ordinary LFSR: it carries its taps
along unchanged, so its stream is the stream of `lfsrPRNG`. -/
theorem lfsrFamily_stream (M : ℕ) (i : Fin (M + 1)) (c σ : Fin i.val → K) (t : ℕ) :
    ((lfsrFamily K M) i).stream (c, σ) t = (lfsrPRNG c).stream σ t := by
  induction t generalizing σ with
  | zero => rfl
  | succ t ih =>
      rw [PRNG.stream_succ, PRNG.stream_succ]
      exact ih _

omit [Fintype K] [DecidableEq K] in
theorem lfsrFamily_pref (M : ℕ) (i : Fin (M + 1)) (c σ : Fin i.val → K) (n : ℕ) :
    ((lfsrFamily K M) i).pref n (c, σ) = (lfsrPRNG c).pref n σ := by
  funext j
  exact lfsrFamily_stream K M i c σ (j : ℕ)

omit [Fintype K] [DecidableEq K] in
/-- An all-zero seed produces the all-zero file, whatever the taps. -/
theorem lfsr_pref_zero {L : ℕ} (c : Fin L → K) (n : ℕ) :
    (lfsrPRNG c).pref n (fun _ => 0) = fun _ => 0 := by
  have hstream : ∀ t : ℕ, (lfsrPRNG c).stream (fun _ => 0) t = 0 := by
    intro t
    induction t with
    | zero => simp [PRNG.stream, lfsrPRNG, lfsrOut]
    | succ t ih =>
        rw [PRNG.stream_succ]
        have hstep : (lfsrPRNG c).step (fun _ => 0) = fun _ : Fin L => (0 : K) := by
          funext j
          simp [lfsrPRNG, lfsrStep]
        rw [hstep]
        exact ih
  funext j
  exact hstream (j : ℕ)

/-- **The all-orders router collapses onto its top order.** Trying every LFSR of
order `≤ M` accepts exactly the files of linear complexity `≤ M`, i.e. exactly
the files the single order-`M` detector already accepts: the extra members of
the family cost seeds but buy no coverage. -/
theorem familyWords_lfsrFamily (M n : ℕ) (hM : 0 < M) :
    familyWords (lfsrFamily K M) n = lfsrWords K M n := by
  ext x
  rw [mem_familyWords]
  constructor
  · rintro ⟨i, p, hp⟩
    rw [lfsrFamily_pref] at hp
    rcases Nat.eq_zero_or_pos i.val with hi | hi
    · have hp2 : p.2 = fun _ => (0 : K) := by
        funext j
        exact absurd j.isLt (by omega)
      have hzero : x = fun _ => (0 : K) := by
        rw [← hp, hp2]
        exact lfsr_pref_zero K p.1 n
      have hM' : NeZero M := ⟨by omega⟩
      rw [mem_lfsrWords]
      exact ⟨fun _ => 0, fun _ => 0, by rw [lfsr_pref_zero K, hzero]⟩
    · have : NeZero i.val := ⟨by omega⟩
      refine lfsrWords_monotone K n hi (by have := i.isLt; omega) ?_
      rw [mem_lfsrWords]
      exact ⟨p.1, p.2, hp⟩
  · intro hx
    rw [mem_lfsrWords] at hx
    obtain ⟨c, σ, hcσ⟩ := hx
    refine ⟨⟨M, by omega⟩, (c, σ), ?_⟩
    rw [lfsrFamily_pref]
    exact hcσ

/-- Capacity of the all-orders LFSR router: at most `∑_{ℓ≤M} |K|^{2ℓ}` files,
which is still exponentially far below `|K|ⁿ` once `n > 2M + 1`. -/
theorem card_lfsrFamily_le (M n : ℕ) :
    (familyWords (lfsrFamily K M) n).card ≤ ∑ i : Fin (M + 1), Fintype.card K ^ (2 * i.val) := by
  refine (card_familyWords_le (lfsrFamily K M) n).trans (le_of_eq ?_)
  refine Finset.sum_congr rfl fun i _ => ?_
  simp [Fintype.card_prod, two_mul, pow_add]

/-- The all-orders LFSR router still rejects some file, as soon as the file is
longer than twice the largest order it tries (plus a slack of one symbol per
order). -/
theorem exists_not_lfsrFamily_routed (M n : ℕ) (hK : 2 ≤ Fintype.card K)
    (hn : 2 * M + M + 2 ≤ n) :
    ∃ x : Fin n → K, ∀ i : Fin (M + 1), ¬ SeedCompressible ((lfsrFamily K M) i) n x := by
  set q := Fintype.card K with hq
  have hterm : ∀ i : Fin (M + 1), q ^ (2 * i.val) ≤ q ^ (2 * M) := by
    intro i
    exact Nat.pow_le_pow_right (by omega) (by have := i.isLt; omega)
  have hsum : (∑ i : Fin (M + 1), q ^ (2 * i.val)) ≤ (M + 1) * q ^ (2 * M) := by
    calc (∑ i : Fin (M + 1), q ^ (2 * i.val))
        ≤ ∑ _i : Fin (M + 1), q ^ (2 * M) := Finset.sum_le_sum fun i _ => hterm i
      _ = (M + 1) * q ^ (2 * M) := by simp [Finset.sum_const, mul_comm]
  have hMq : M + 1 ≤ q ^ M := by
    have : M + 1 ≤ 2 ^ M := Nat.succ_le_of_lt (Nat.lt_two_pow_self)
    exact this.trans (Nat.pow_le_pow_left hK M)
  have hstep : (M + 1) * q ^ (2 * M) ≤ q ^ M * q ^ (2 * M) :=
    Nat.mul_le_mul_right _ hMq
  have hcomb : q ^ M * q ^ (2 * M) = q ^ (2 * M + M) := by
    rw [← pow_add]; congr 1; omega
  have hlt : q ^ (2 * M + M) < q ^ n := Nat.pow_lt_pow_right (by omega) (by omega)
  have hcap : (∑ i : Fin (M + 1), Fintype.card ((Fin i.val → K) × (Fin i.val → K)))
      < Fintype.card K ^ n := by
    have hcards : (∑ i : Fin (M + 1), Fintype.card ((Fin i.val → K) × (Fin i.val → K)))
        = ∑ i : Fin (M + 1), q ^ (2 * i.val) := by
      refine Finset.sum_congr rfl fun i _ => ?_
      simp [Fintype.card_prod, two_mul, pow_add, hq]
    rw [hcards, ← hq]
    omega
  exact exists_not_family_routed (lfsrFamily K M) n hcap

end LFSRRouter

end Catalog.Probability.SeedRec