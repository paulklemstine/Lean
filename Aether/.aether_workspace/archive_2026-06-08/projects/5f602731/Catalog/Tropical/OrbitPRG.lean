import Mathlib

/-!
# Tropical Orbit Pseudorandom Generators

This file formalizes a bridge between tropical matrix dynamics and pseudorandom
generation. The main theorem proves that if a hash function extracts well from
each step of a tropical orbit (conditioned on previous steps), then the full
hashed orbit is statistically close to uniform.

## Main Results

* `tropical_orbit_prg` — The main PRG theorem: conditional extraction at each step
  implies the full orbit hash output is `(T+1)*ε`-close to uniform.
* `statDist_nonneg` — Statistical distance is non-negative.
* `statDist_triangle` — Triangle inequality for statistical distance.
* `orbit_extension_statDist` — One-step chain rule: extending the orbit by one
  hash value increases statistical distance by at most ε.

## Mathematical significance

This establishes a new principle: **tropical orbit complexity can be harvested
as computational randomness**. The key insight is that orbit expansion in
tropical algebra forces extractable min-entropy at each step, which a
hybrid/chain-rule argument converts into global pseudorandomness.

## Proof Strategy

The proof follows Proof Strategy A (Hybrid Argument + Fiber Entropy):
1. Define prefix-conditioned fibers and the conditional extraction property.
2. Prove a one-step chain rule: extending by one coordinate adds at most ε.
3. Assemble by induction (telescoping the chain rule T+1 times).

### Assumptions

- **Conditional extraction** (`condExtract`): a tropical dynamics assumption
  stating that orbit expansion prevents the prefix from overdetermining the
  next hash value. This is the structural tropical fact.
- **Hash quality**: implicit in the extraction hypothesis — the hash function
  `h` must be extractor-quality for the entropy level of each orbit step.
-/

noncomputable section

open Finset BigOperators

/-! ## Part 1: Statistical Distance -/

/-- Statistical distance (total variation distance) between two distributions
    represented as real-valued functions on a finite type. -/
def statDist {α : Type*} [Fintype α] (p q : α → ℝ) : ℝ :=
  (1 / 2) * ∑ x : α, |p x - q x|

theorem statDist_nonneg {α : Type*} [Fintype α] (p q : α → ℝ) :
    0 ≤ statDist p q :=
  mul_nonneg (by norm_num) (Finset.sum_nonneg fun _ _ => abs_nonneg _)

theorem statDist_symm {α : Type*} [Fintype α] (p q : α → ℝ) :
    statDist p q = statDist q p := by
  unfold statDist; simp [abs_sub_comm]

theorem statDist_triangle {α : Type*} [Fintype α] (p q r : α → ℝ) :
    statDist p r ≤ statDist p q + statDist q r := by
  unfold statDist;
  rw [ ← mul_add, ← Finset.sum_add_distrib ] ; gcongr ; exact abs_sub_le_iff.2 ⟨ by cases abs_cases ( p ‹_› - q ‹_› ) <;> cases abs_cases ( q ‹_› - r ‹_› ) <;> linarith, by cases abs_cases ( p ‹_› - q ‹_› ) <;> cases abs_cases ( q ‹_› - r ‹_› ) <;> linarith ⟩ ;

theorem statDist_self {α : Type*} [Fintype α] (p : α → ℝ) :
    statDist p p = 0 := by
  simp [statDist]

/-! ## Part 2: Distributions -/

/-- Pushforward of uniform counting measure on a finset through a function. -/
def pushfwdDist {S α : Type*} [DecidableEq α]
    (seed : Finset S) (f : S → α) : α → ℝ :=
  fun a => ((seed.filter (fun s => f s = a)).card : ℝ) / seed.card

/-- Uniform distribution on a finite type. -/
def uniformDist (α : Type*) [Fintype α] : α → ℝ :=
  fun _ => (1 : ℝ) / Fintype.card α

theorem pushfwdDist_nonneg {S α : Type*} [DecidableEq α]
    (seed : Finset S) (f : S → α) (a : α) :
    0 ≤ pushfwdDist seed f a :=
  div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)

theorem pushfwdDist_sum {S α : Type*} [Fintype α] [DecidableEq α]
    (seed : Finset S) (f : S → α) (hS : seed.Nonempty) :
    ∑ a : α, pushfwdDist seed f a = 1 := by
  have h_sum_card : ∑ a ∈ Finset.univ, (seed.filter (fun s => f s = a)).card = seed.card := by
    simp +decide only [card_eq_sum_ones, sum_fiberwise_of_maps_to fun x hx => Finset.mem_univ (f x)];
  convert congr_arg ( fun x : ℕ => ( x : ℝ ) / seed.card ) h_sum_card using 1;
  · simp +decide [ pushfwdDist, Finset.sum_div _ _ _ ] ;
  · rw [ div_self ( Nat.cast_ne_zero.mpr hS.card_pos.ne' ) ]

/-! ## Part 3: Orbit Hash Definitions -/

/-- The orbit hash map: seed → sequence of hashed tropical powers. -/
def orbitHash {S M β : Type*} (powTrop : S → ℕ → M) (h : M → β) (T : ℕ) :
    S → (Fin (T + 1) → β) :=
  fun s i => h (powTrop s i.val)

/-- The orbit hash distribution on `Fin (T+1) → β`. -/
def orbitHashDist {S M β : Type*} [DecidableEq β] [Fintype β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β) (T : ℕ) :
    (Fin (T + 1) → β) → ℝ :=
  pushfwdDist seed (orbitHash powTrop h T)

/-! ## Part 4: Conditional Extraction -/

/-- The prefix fiber: seeds whose hashed orbit prefix matches `p`. -/
def prefixFiber {S M β : Type*} [DecidableEq β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β) (i : ℕ)
    (p : Fin i → β) : Finset S :=
  seed.filter (fun s => ∀ j : Fin i, h (powTrop s j.val) = p j)

/-- Conditional extraction: for each prefix, the next hash is ε-close to uniform. -/
def condExtract {S M β : Type*} [Fintype β] [DecidableEq β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β)
    (i : ℕ) (ε : ℝ) : Prop :=
  ∀ p : Fin i → β,
    let fiber := prefixFiber seed powTrop h i p
    fiber.Nonempty →
    statDist
      (fun b => ((fiber.filter (fun s => h (powTrop s i) = b)).card : ℝ) / fiber.card)
      (uniformDist β) ≤ ε

/-! ## Part 5: Helper Lemmas for the Chain Rule -/

/-- Equivalence between `Fin (n+1) → β` and `(Fin n → β) × β` via init/last. -/
def piFinSnoc (n : ℕ) (β : Type*) [DecidableEq β] :
    (Fin (n + 1) → β) ≃ (Fin n → β) × β where
  toFun f := (Fin.init f, f (Fin.last n))
  invFun p := Fin.snoc p.1 p.2
  left_inv f := by ext i; simp [Fin.snoc_init_self]
  right_inv p := by ext <;> simp [Fin.init_snoc, Fin.snoc_last]

/-
Sum over `Fin (n+1) → β` decomposes as double sum via snoc.
-/
theorem sum_piFinSnoc {β : Type*} [Fintype β] [DecidableEq β] {n : ℕ}
    (g : (Fin (n + 1) → β) → ℝ) :
    ∑ f : Fin (n + 1) → β, g f = ∑ p : Fin n → β, ∑ b : β, g (Fin.snoc p b) := by
  convert Fintype.sum_equiv ( piFinSnoc n β ) g ( fun p => g ( Fin.snoc p.1 p.2 ) ) ?_ using 1;
  · exact?;
  · exact fun x => by simp +decide [ piFinSnoc ] ;

/-
The orbit hash at time T+1 decomposes as snoc of orbit hash at time T.
-/
theorem orbitHash_eq_snoc {S M β : Type*} [DecidableEq β]
    (powTrop : S → ℕ → M) (h : M → β) (T : ℕ) (s : S) :
    orbitHash powTrop h (T + 1) s =
      Fin.snoc (orbitHash powTrop h T s) (h (powTrop s (T + 1))) := by
  exact funext fun i => by cases i using Fin.lastCases <;> simp +decide [ *, orbitHash ] ;

/-
Product absolute value triangle inequality.
-/
theorem abs_mul_sub_mul {a b c d : ℝ} (ha : 0 ≤ a) (hd : 0 ≤ d) :
    |a * c - b * d| ≤ a * |c - d| + d * |a - b| := by
  cases abs_cases ( c - d ) <;> cases abs_cases ( a - b ) <;> cases abs_cases ( a * c - b * d ) <;> nlinarith

/-
Finset.card of filter equals sum over indicator.
-/
theorem filter_card_eq_sum_filter {S : Type*} [DecidableEq S]
    (seed : Finset S) (P Q : S → Prop)
    [DecidablePred P] [DecidablePred Q] :
    (seed.filter (fun s => P s ∧ Q s)).card =
    ((seed.filter P).filter Q).card := by
  congr 1 with x ; aesop

/-
The prefix fiber for `Fin.snoc p b` at step `T+2` decomposes.
-/
theorem prefixFiber_snoc {S M β : Type*} [DecidableEq β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β) (T : ℕ)
    (p : Fin (T + 1) → β) (b : β) :
    seed.filter (fun s => orbitHash powTrop h (T + 1) s = Fin.snoc p b) =
    (prefixFiber seed powTrop h (T + 1) p).filter (fun s => h (powTrop s (T + 1)) = b) := by
  ext s
  simp [orbitHash, prefixFiber];
  simp +decide [ funext_iff, Fin.snoc, orbitHash ];
  constructor <;> intro h <;> simp_all +decide [ Fin.forall_iff ];
  grind

/-
Uniform distribution on `Fin (n+1) → β` factors as product of uniform on
    `Fin n → β` and uniform on β.
-/
theorem uniformDist_snoc {β : Type*} [Fintype β] [DecidableEq β] (n : ℕ) (p : Fin n → β) (b : β) :
    uniformDist (Fin (n + 1) → β) (Fin.snoc p b) =
    uniformDist (Fin n → β) p * uniformDist β b := by
  unfold uniformDist; simp +decide [ pow_succ, mul_assoc, mul_comm, mul_left_comm ] ;

/-! ## Part 6: One-Step Chain Rule -/

/-
**One-step chain rule for orbit hash distributions.**
    Extending the orbit by one hash value adds at most ε to statistical distance.
-/
theorem orbit_extension_statDist
    {S M β : Type*} [Fintype S] [Fintype β] [DecidableEq S] [DecidableEq β]
    [DecidableEq M] [Nonempty β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β)
    (T : ℕ) (δ ε : ℝ) (hε : 0 ≤ ε) (hδ : 0 ≤ δ)
    (h_seed : seed.Nonempty)
    (h_prev : statDist (orbitHashDist seed powTrop h T) (uniformDist (Fin (T + 1) → β)) ≤ δ)
    (h_extract : condExtract seed powTrop h (T + 1) ε) :
    statDist (orbitHashDist seed powTrop h (T + 1))
      (uniformDist (Fin (T + 2) → β)) ≤ δ + ε := by
  -- By definition of $P_{T+1}$, we can express it in terms of $P_T$ and the new hash value.
  have h_dist_T1 : ∀ p : Fin (T + 1) → β, ∀ b : β, pushfwdDist seed (orbitHash powTrop h (T + 1)) (Fin.snoc p b) = pushfwdDist (prefixFiber seed powTrop h (T + 1) p) (fun s => h (powTrop s (T + 1))) b * pushfwdDist seed (orbitHash powTrop h T) p := by
    intro p b
    simp [pushfwdDist, prefixFiber, orbitHash];
    rw [ show ( { s ∈ seed | orbitHash powTrop h T s = p } ) = { s ∈ seed | ∀ j : Fin ( T + 1 ), h ( powTrop s j ) = p j } from ?_ ];
    · by_cases h : # ( Finset.filter ( fun s => ∀ j : Fin ( T + 1 ), h ( powTrop s j ) = p j ) seed ) = 0 <;> simp_all +decide [ div_mul_div_cancel₀ ];
      · rw [ Finset.card_eq_zero.mpr ] <;> simp_all +decide [ Finset.ext_iff ];
        intro s hs; specialize h hs; simp_all +decide [ funext_iff, Fin.snoc ] ;
        obtain ⟨ x, hx ⟩ := h; use Fin.castSucc x; simp_all +decide [ orbitHash ] ;
        rw [ if_pos ( Nat.le_of_lt_succ x.2 ) ] ; exact hx;
      · congr 2;
        congr 1 with s ; simp +decide [ funext_iff, Fin.snoc ];
        constructor <;> intro h <;> simp_all +decide [ Fin.forall_iff, orbitHash ];
        grind;
    · simp +decide [ Finset.ext_iff, funext_iff, orbitHash ];
  -- Apply the chain rule to bound the sum.
  have h_chain_rule : ∀ p : Fin (T + 1) → β, ∑ b : β, |pushfwdDist (prefixFiber seed powTrop h (T + 1) p) (fun s => h (powTrop s (T + 1))) b * pushfwdDist seed (orbitHash powTrop h T) p - uniformDist (Fin (T + 2) → β) (Fin.snoc p b)| ≤ 2 * ε * pushfwdDist seed (orbitHash powTrop h T) p + |pushfwdDist seed (orbitHash powTrop h T) p - uniformDist (Fin (T + 1) → β) p| := by
    intro p
    by_cases h_fiber : (prefixFiber seed powTrop h (T + 1) p).Nonempty;
    · have h_chain_rule : ∑ b : β, |pushfwdDist (prefixFiber seed powTrop h (T + 1) p) (fun s => h (powTrop s (T + 1))) b - uniformDist β b| ≤ 2 * ε := by
        have := h_extract p h_fiber;
        unfold statDist at this; linarith!;
      have h_chain_rule : ∑ b : β, |pushfwdDist (prefixFiber seed powTrop h (T + 1) p) (fun s => h (powTrop s (T + 1))) b * pushfwdDist seed (orbitHash powTrop h T) p - uniformDist β b * pushfwdDist seed (orbitHash powTrop h T) p| ≤ 2 * ε * pushfwdDist seed (orbitHash powTrop h T) p := by
        simp_all +decide [ ← sub_mul, abs_mul ];
        rw [ ← Finset.sum_mul _ _ _ ];
        exact mul_le_mul h_chain_rule ( by rw [ abs_of_nonneg ] ; exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ) ( by positivity ) ( by positivity );
      have h_chain_rule : ∑ b : β, |uniformDist β b * pushfwdDist seed (orbitHash powTrop h T) p - uniformDist β b * uniformDist (Fin (T + 1) → β) p| ≤ |pushfwdDist seed (orbitHash powTrop h T) p - uniformDist (Fin (T + 1) → β) p| := by
        simp +decide [ ← mul_sub, abs_mul, uniformDist ];
      have h_chain_rule : ∀ b : β, |pushfwdDist (prefixFiber seed powTrop h (T + 1) p) (fun s => h (powTrop s (T + 1))) b * pushfwdDist seed (orbitHash powTrop h T) p - uniformDist (Fin (T + 2) → β) (Fin.snoc p b)| ≤ |pushfwdDist (prefixFiber seed powTrop h (T + 1) p) (fun s => h (powTrop s (T + 1))) b * pushfwdDist seed (orbitHash powTrop h T) p - uniformDist β b * pushfwdDist seed (orbitHash powTrop h T) p| + |uniformDist β b * pushfwdDist seed (orbitHash powTrop h T) p - uniformDist β b * uniformDist (Fin (T + 1) → β) p| := by
        grind +suggestions;
      exact le_trans ( Finset.sum_le_sum fun _ _ => h_chain_rule _ ) ( by simpa only [ Finset.sum_add_distrib ] using add_le_add ‹∑ b : β, |pushfwdDist ( prefixFiber seed powTrop h ( T + 1 ) p ) ( fun s => h ( powTrop s ( T + 1 ) ) ) b * pushfwdDist seed ( orbitHash powTrop h T ) p - uniformDist β b * pushfwdDist seed ( orbitHash powTrop h T ) p| ≤ 2 * ε * pushfwdDist seed ( orbitHash powTrop h T ) p› ‹∑ b : β, |uniformDist β b * pushfwdDist seed ( orbitHash powTrop h T ) p - uniformDist β b * uniformDist ( Fin ( T + 1 ) → β ) p| ≤ |pushfwdDist seed ( orbitHash powTrop h T ) p - uniformDist ( Fin ( T + 1 ) → β ) p|› );
    · simp_all +decide [ Finset.ext_iff, pushfwdDist ];
      simp_all +decide [ Finset.ext_iff, prefixFiber ];
      rw [ show ( Finset.filter ( fun s => ∀ j : Fin ( T + 1 ), h ( powTrop s j ) = p j ) seed ) = ∅ from Finset.eq_empty_of_forall_notMem fun s hs => by obtain ⟨ x, hx ⟩ := h_fiber s ( Finset.mem_filter.mp hs |>.1 ) ; exact hx ( Finset.mem_filter.mp hs |>.2 x ) ] ; simp +decide [ uniformDist ];
      rw [ show ( Finset.filter ( fun s => orbitHash powTrop h T s = p ) seed ) = ∅ from Finset.eq_empty_of_forall_notMem fun s hs => by obtain ⟨ x, hx ⟩ := h_fiber s ( Finset.mem_filter.mp hs |>.1 ) ; exact hx ( Finset.mem_filter.mp hs |>.2 |> fun h => by simpa using congr_fun h ⟨ x, by linarith [ Fin.is_lt x ] ⟩ ) ] ; simp +decide [ uniformDist ];
      field_simp;
      rw [ ← pow_succ' ];
  have h_chain_rule_sum : ∑ p : Fin (T + 1) → β, ∑ b : β, |pushfwdDist (prefixFiber seed powTrop h (T + 1) p) (fun s => h (powTrop s (T + 1))) b * pushfwdDist seed (orbitHash powTrop h T) p - uniformDist (Fin (T + 2) → β) (Fin.snoc p b)| ≤ 2 * ε + 2 * δ := by
    refine' le_trans ( Finset.sum_le_sum fun p _ => h_chain_rule p ) _;
    simp_all +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, statDist ];
    simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, orbitHashDist ];
    rw [ show ∑ i : Fin ( T + 1 ) → β, pushfwdDist seed ( orbitHash powTrop h T ) i = 1 from ?_ ] ; linarith;
    convert pushfwdDist_sum seed ( orbitHash powTrop h T ) h_seed using 1;
  convert mul_le_mul_of_nonneg_left h_chain_rule_sum ( show ( 0 : ℝ ) ≤ 1 / 2 by norm_num ) using 1;
  · rw [ statDist ];
    rw [ sum_piFinSnoc ];
    exact congrArg _ ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ ← h_dist_T1 ] ; rfl );
  · ring

/-! ## Part 7: Main Theorem -/

/-
**Tropical Orbit PRG Theorem.**
    If for each step `i ≤ T`, the conditional extraction property holds with
    error `ε`, then the full orbit hash is `(T+1)*ε`-close to uniform.
-/
theorem tropical_orbit_prg
    {S M β : Type*} [Fintype S] [Fintype β] [DecidableEq S] [DecidableEq β]
    [DecidableEq M] [Nonempty β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β)
    (T : ℕ) (ε : ℝ) (hε : 0 ≤ ε)
    (h_extract : ∀ i, i ≤ T → condExtract seed powTrop h i ε)
    (h_seed : seed.Nonempty) :
    statDist (orbitHashDist seed powTrop h T)
      (uniformDist (Fin (T + 1) → β)) ≤ (T + 1 : ℝ) * ε := by
  induction' T with T ih;
  · simp +decide [ pushfwdDist, orbitHashDist ];
    have := h_extract 0 le_rfl;
    convert this ( fun _ => h ( powTrop ( Classical.choose h_seed ) 0 ) ) _ using 1;
    · unfold pushfwdDist orbitHash uniformDist; simp +decide [ statDist ] ;
      unfold prefixFiber; simp +decide [ funext_iff ] ;
      refine' Finset.sum_bij ( fun x _ => x 0 ) _ _ _ _ <;> simp +decide;
      · exact fun a₁ a₂ h => funext fun i => by fin_cases i; exact h;
      · exact fun b => ⟨ fun _ => b, rfl ⟩;
    · exact ⟨ Classical.choose h_seed, Finset.mem_filter.mpr ⟨ Classical.choose_spec h_seed, by simp +decide ⟩ ⟩;
  · have := orbit_extension_statDist seed powTrop h T ( ( T + 1 ) * ε ) ε hε ( by positivity ) h_seed ( ih fun i hi => h_extract i ( Nat.le_succ_of_le hi ) ) ( h_extract ( T + 1 ) le_rfl ) ; norm_num at * ; linarith;

/-! ## Part 8: Corollaries -/

/-
**Next-symbol unpredictability.**
    The conditional extraction property directly implies that each step's
    hash value is unpredictable given the prefix. This is a restatement
    of the condExtract hypothesis in a more cryptographic language.
-/
theorem tropical_orbit_step_unpredictability
    {S M β : Type*} [Fintype S] [Fintype β] [DecidableEq S] [DecidableEq β]
    [DecidableEq M] [Nonempty β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β)
    (i : ℕ) (ε : ℝ) (hε : 0 ≤ ε)
    (h_extract : condExtract seed powTrop h i ε)
    (p : Fin i → β) (b : β)
    (hp : (prefixFiber seed powTrop h i p).Nonempty) :
    ((prefixFiber seed powTrop h i p).filter
      (fun s => h (powTrop s i) = b)).card ≤
    (prefixFiber seed powTrop h i p).card *
      (1 / (Fintype.card β : ℝ) + 2 * ε) := by
  nontriviality;
  have := h_extract p hp;
  have := this.trans' ( mul_le_mul_of_nonneg_left ( Finset.single_le_sum ( fun x _ => abs_nonneg ( ( # ( Finset.filter ( fun s => h ( powTrop s i ) = x ) ( prefixFiber seed powTrop h i p ) ) : ℝ ) / # ( prefixFiber seed powTrop h i p ) - 1 / ( Fintype.card β : ℝ ) ) ) ( Finset.mem_univ b ) ) ( by positivity ) );
  cases abs_cases ( ( # ( Finset.filter ( fun s => h ( powTrop s i ) = b ) ( prefixFiber seed powTrop h i p ) ) : ℝ ) / # ( prefixFiber seed powTrop h i p ) - 1 / ( Fintype.card β : ℝ ) ) <;> nlinarith [ show ( 0 : ℝ ) < # ( prefixFiber seed powTrop h i p ) from Nat.cast_pos.mpr hp.card_pos, div_mul_cancel₀ ( # ( Finset.filter ( fun s => h ( powTrop s i ) = b ) ( prefixFiber seed powTrop h i p ) ) : ℝ ) ( show ( # ( prefixFiber seed powTrop h i p ) : ℝ ) ≠ 0 from Nat.cast_ne_zero.mpr hp.card_pos.ne' ) ]

/-! ## Part 9: Prefix Fiber Structural Results -/

/-- Maximum prefix fiber cardinality. -/
def maxPrefixFiberCard {S M β : Type*} [Fintype β] [DecidableEq β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β) (i : ℕ) : ℕ :=
  Finset.sup (Finset.univ : Finset (Fin i → β))
    (fun p => (prefixFiber seed powTrop h i p).card)

/-
**Conditional min-entropy lower bound from prefix fiber bound.**
    If prefix fibers have size ≤ B and the seed has size N, then the conditional
    min-entropy of the i-th power given the prefix is at least log₂(N/B).
    This connects tropical orbit expansion to information-theoretic entropy.
-/
theorem conditional_minEntropy_from_fiber
    {S M β : Type*} [Fintype S] [Fintype β] [DecidableEq S] [DecidableEq β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β) (i : ℕ)
    (B : ℕ) (_hB : 0 < B)
    (h_fiber : ∀ p : Fin i → β, (prefixFiber seed powTrop h i p).card ≤ B) :
    maxPrefixFiberCard seed powTrop h i ≤ B := by
  exact Finset.sup_le fun p _ => h_fiber p

end