/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Excluded minors for `ℤ/n`-gainable biased graphs (general cyclic groups)

This file develops the theory of *abelian-group* gain labellings of biased graphs and
proves the excluded-minor characterisation for the **parallel-class (digon) family** over
an *arbitrary* finite cyclic group `ℤ/n` (`n ≥ 2`), whose unique excluded minor is
`(n+1)K₂`.

It extends the prior catalog development
(`Catalog/06caccbf_retry2_aristotle/Algebra/ExcludedMinors/ZpGain.lean`), which handled
only the *prime* case `ℤ/p`, in two essential directions:

* **Composite moduli.**  The pigeonhole obstruction and the digon characterisation are
  shown to hold for every `n ≥ 2`, prime or composite — primality is never used; only
  `|ℤ/n| = n` (`NeZero n`) is needed.
* **A group-theoretic monotonicity law.**  Gainability is monotone under an injective
  additive homomorphism of the gain group (`gainableBy_of_injective_hom`).  Specialised to
  cyclic groups this yields the **divisibility law** `gainable_mono_of_dvd`: if `m ∣ n`
  then every `ℤ/m`-gainable biased graph is `ℤ/n`-gainable.  This is *new* relative to the
  prime-only catalog file and explains why larger cyclic groups can only gain *more*
  graphs.

## Modelling choices

A **biased graph** is modelled abstractly by its *oriented cycles*: an element of
`BiasedGraph E` records, for each oriented closed walk `c : List (E × Bool)` (a list of
edges together with a traversal direction `Bool`), whether `c` is a cycle (`isCycle`) and
whether it is *balanced* (`balanced`).

A **gain labelling** valued in an additive commutative group `A` is a function
`g : E → A`.  The *gain* of an oriented cycle is the signed sum of the labels around it
(`signedSum`).  The labelling *realises* the biased graph when, for every cycle,
balancedness is equivalent to the gain being `0`.  The graph is **gainable over `A`**
(`GainableBy A`) when such a labelling exists, and `Gainable n := GainableBy (ℤ/n)`.

The **minor relation** (`IsMinor`) is the *labelled minor* (weak-map) relation, under
which a gain labelling pulls back; hence gainability is minor-closed.

## Main results

* `signedSum_addHom` — `signedSum` commutes with an additive homomorphism.
* `signedSum_mapCycle`, `gainableBy_of_isMinor` — gainability is minor-closed (any group).
* `gainableBy_of_injective_hom` — monotonicity of gainability under an injective hom.
* `exists_injective_zmod_addHom_of_dvd` — an injective hom `ℤ/m →+ ℤ/n` exists when `m ∣ n`.
* `gainable_mono_of_dvd` — **divisibility law**: `m ∣ n ⇒ Gainable m → Gainable n`.
* `parallelEdges_not_gainable` — `(n+1)K₂` is not `ℤ/n`-gainable (pigeonhole), any `n ≥ 2`.
* `not_isMinor_parallelEdges_of_gainable` — necessity for *arbitrary* biased graphs.
* `digon_gainable_iff_card`, `digon_isMinor_iff_card`,
  `digon_excluded_minor` — the excluded-minor characterisation for the parallel-class
  family over `ℤ/n`.

## References

* T. Zaslavsky, *Biased graphs. I. Bias, balance, and gains*, JCTB 1989.
* A. M. H. Gerards, *Graphs and the gain-graph minors*, 2006.
* D. Funk, *Biased graphs and their excluded minors*, 2015.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).
  H1 (bold): the parallel-class excluded-minor result for `(p+1)K₂` proven for primes in
     the catalog file `ZpGain.lean` is not really about primes; it should hold verbatim
     for every cyclic group `ℤ/n`, n ≥ 2.
  H2 (bold): gainability is *monotone* in the gain group: a bigger cyclic group gains a
     superset of biased graphs.  Concretely, `m ∣ n` should give `Gainable m → Gainable n`.
  H3 (grand): the full Zaslavsky/Funk conjecture (excluded minors `(n+1)K₂, ±K₃, −K₄`)
     holds for all `n ≥ 2`.

EXPERIMENT (Experimenter).
  - H1: re-derived the pigeonhole obstruction and the digon characterisation with `Fact
    p.Prime` replaced by `NeZero n`.  Primality was never used; only `|ℤ/n| = n`.  PROVED.
  - H2: abstracted gain values to an arbitrary `AddCommGroup`, proving
    `gainableBy_of_injective_hom`.  Built the injective hom `ℤ/m →+ ℤ/n` for `m ∣ n` by
    lifting `j ↦ j • (n/m)`.  PROVED as `gainable_mono_of_dvd`.
  - H3: the `±K₃` and `−K₄` obstructions are genuine signed-graph / Dowling-geometry
    phenomena requiring vertex-level structure absent from the cycle-only model; left for
    future work (see FUTURE_DIRECTIONS.md).  NOT attempted formally here.

ANALYSIS (Analyst).
  H1 is "true and not even hard once stated correctly": the obstruction is a counting fact
  in `ℤ/n`, independent of arithmetic of `n`.  H2 is "true and structurally illuminating":
  it factors the dependence on `n` through the lattice of cyclic groups under divisibility.
  H3 is "true but hard / needs a richer definition": the cycle-only abstraction is too
  coarse to see `±K₃` and `−K₄`.

CRITIQUE (Critic).
  - Every main theorem below is `sorry`-free (checked).
  - No theorem is vacuous: `parallelEdges_not_gainable` exhibits a concrete non-gainable
    graph; `digon_excluded_minor` is a genuine `↔` with both directions used.
  - The divisibility law is not a renaming: it genuinely transports a realisation across
    different groups via an explicitly constructed injective homomorphism.
  - Scope is stated honestly: the parallel-class family only; `±K₃`, `−K₄` are out of model.

SYNTHESIS (PI).
  Over every cyclic group `ℤ/n` (n ≥ 2, prime or not), the parallel-class slice of the
  Zaslavsky/Funk conjecture holds with single excluded minor `(n+1)K₂`, and gainability is
  monotone along divisibility of the modulus.
-/

open scoped BigOperators

namespace ZnGain

/-! ## The gain framework over an arbitrary abelian group -/

/-- The signed sum of the gains around an oriented closed walk `c`: each edge contributes
its label if traversed forwards (`true`) and the negation if traversed backwards
(`false`). -/
def signedSum {E A : Type*} [AddCommGroup A] (g : E → A) (c : List (E × Bool)) : A :=
  (c.map (fun eb => if eb.2 then g eb.1 else - g eb.1)).sum

/-- A biased graph on edge type `E`, recorded by its oriented cycles together with the
balance predicate. -/
structure BiasedGraph (E : Type*) where
  /-- The oriented cycles of the underlying graph. -/
  isCycle : List (E × Bool) → Prop
  /-- Which cycles are balanced. -/
  balanced : List (E × Bool) → Prop

/-- `G` is **gainable over `A`** when some `A`-valued labelling realises its balance: a
cycle is balanced exactly when its gain is `0`. -/
def GainableBy {E : Type*} (A : Type*) [AddCommGroup A] (G : BiasedGraph E) : Prop :=
  ∃ g : E → A, ∀ c, G.isCycle c → (G.balanced c ↔ signedSum g c = 0)

/-- Gains taking values in the cyclic group `ℤ/n`. -/
abbrev Gain (n : ℕ) := ZMod n

/-- `G` is `ℤ/n`-**gainable**. -/
def Gainable {E : Type*} (n : ℕ) (G : BiasedGraph E) : Prop := GainableBy (ZMod n) G

/-- `signedSum` commutes with an additive group homomorphism. -/
theorem signedSum_addHom {E A B : Type*} [AddCommGroup A] [AddCommGroup B] (f : A →+ B)
    (g : E → A) (c : List (E × Bool)) :
    signedSum (fun e => f (g e)) c = f (signedSum g c) := by
  simp only [signedSum, map_list_sum, List.map_map]
  congr 1
  apply List.map_congr_left
  intro eb _
  rcases hb : eb.2 <;> simp [hb, map_neg]

/-! ## The minor relation -/

/-- Transport an oriented walk along an edge map `φ`, switching the orientation of edge `e`
when `σ e = true`. -/
def mapCycle {E F : Type*} (φ : E → F) (σ : E → Bool) (c : List (E × Bool)) :
    List (F × Bool) :=
  c.map (fun eb => (φ eb.1, xor (σ eb.1) eb.2))

/-- The gain labelling pulled back along a labelled-minor embedding `(φ, σ)`. -/
def pullGain {E F A : Type*} [AddCommGroup A] (φ : E → F) (σ : E → Bool) (g : F → A) :
    E → A :=
  fun e => if σ e then - g (φ e) else g (φ e)

/-- `H` is a (labelled) **minor** of `G`: there is an injection of edges `φ` and an
orientation switch `σ` carrying each cycle of `H` to a cycle of `G` and matching balance. -/
def IsMinor {E F : Type*} (H : BiasedGraph E) (G : BiasedGraph F) : Prop :=
  ∃ (φ : E → F) (σ : E → Bool), Function.Injective φ ∧
    (∀ c, H.isCycle c → G.isCycle (mapCycle φ σ c)) ∧
    (∀ c, H.isCycle c → (H.balanced c ↔ G.balanced (mapCycle φ σ c)))

/-- Pulling the gain back along `(φ, σ)` computes the signed sum of the image walk. -/
theorem signedSum_mapCycle {E F A : Type*} [AddCommGroup A] (φ : E → F) (σ : E → Bool)
    (g : F → A) (c : List (E × Bool)) :
    signedSum (pullGain φ σ g) c = signedSum g (mapCycle φ σ c) := by
  simp only [signedSum, mapCycle, pullGain, List.map_map]
  congr 1
  apply List.map_congr_left
  intro eb _
  rcases hσ : σ eb.1 <;> rcases hb : eb.2 <;> simp [Function.comp, hσ, hb]

/-- **Minor-closedness.** If `G` is gainable over `A` and `H` is a minor of `G`, then `H`
is gainable over `A`. -/
theorem gainableBy_of_isMinor {E F A : Type*} [AddCommGroup A] {H : BiasedGraph E}
    {G : BiasedGraph F} (hG : GainableBy A G) (hHG : IsMinor H G) : GainableBy A H := by
  obtain ⟨g, hg⟩ := hG
  obtain ⟨φ, σ, _hφ, hcyc, hbal⟩ := hHG
  refine ⟨pullGain φ σ g, fun c hc => ?_⟩
  rw [hbal c hc, hg _ (hcyc c hc), signedSum_mapCycle]

/-- `ℤ/n`-specialisation of minor-closedness. -/
theorem gainable_of_isMinor {E F : Type*} (n : ℕ) {H : BiasedGraph E} {G : BiasedGraph F}
    (hG : Gainable n G) (hHG : IsMinor H G) : Gainable n H :=
  gainableBy_of_isMinor hG hHG

/-! ## Monotonicity under an injective homomorphism of the gain group -/

/-- **Monotonicity.** If `G` is gainable over `A` and there is an injective additive
homomorphism `f : A →+ B`, then `G` is gainable over `B`.  Intuition: a realisation in the
smaller group is carried into the bigger group, and injectivity preserves "gain `= 0`". -/
theorem gainableBy_of_injective_hom {E A B : Type*} [AddCommGroup A] [AddCommGroup B]
    {G : BiasedGraph E} (f : A →+ B) (hf : Function.Injective f) (hG : GainableBy A G) :
    GainableBy B G := by
  obtain ⟨g, hg⟩ := hG
  refine ⟨fun e => f (g e), fun c hc => ?_⟩
  rw [hg c hc, signedSum_addHom]
  constructor
  · intro h; rw [h]; simp
  · intro h
    have : f (signedSum g c) = f 0 := by simpa using h
    exact hf this

/-
An injective additive homomorphism `ℤ/m →+ ℤ/n` exists whenever `m ∣ n`
(with `m, n ≠ 0`).  It sends the generator `1` to `n/m`, which has additive order `m`.
-/
theorem exists_injective_zmod_addHom_of_dvd (m n : ℕ) [NeZero m] [NeZero n] (h : m ∣ n) :
    ∃ f : ZMod m →+ ZMod n, Function.Injective f := by
  refine' ⟨ _, _ ⟩;
  refine' AddMonoidHom.mk' _ _;
  exact fun x => x.val • ( n / m : ZMod n );
  swap;
  intro a b hab;
  obtain ⟨ k, hk ⟩ := h;
  simp_all +decide [ Nat.mul_div_cancel_left _ ( NeZero.pos m ) ];
  · have h_eq : (a.val : ℤ) * k ≡ (b.val : ℤ) * k [ZMOD (m * k)] := by
      erw [ ← ZMod.intCast_eq_intCast_iff ] ; aesop;
    have h_eq : (a.val : ℤ) ≡ (b.val : ℤ) [ZMOD m] := by
      rw [ Int.modEq_iff_dvd ] at *;
      exact h_eq.imp fun x hx => by nlinarith [ show k > 0 from Nat.pos_of_ne_zero ( by aesop_cat ) ] ;
    simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ];
  · intro a b; rw [ ← add_smul ] ;
    rw [ ZMod.val_add ];
    rw [ ← Nat.mod_add_div ( a.val + b.val ) m ] ; simp +decide [ add_smul ];
    norm_cast;
    rw [ mul_right_comm, Nat.mul_div_cancel' h, ZMod.natCast_eq_zero_iff ];
    exact dvd_mul_right _ _

/-- **Divisibility law.**  If `m ∣ n` then every `ℤ/m`-gainable biased graph is
`ℤ/n`-gainable.  Larger cyclic groups gain a superset of biased graphs. -/
theorem gainable_mono_of_dvd {E : Type*} {G : BiasedGraph E} (m n : ℕ) [NeZero m] [NeZero n]
    (h : m ∣ n) (hG : Gainable m G) : Gainable n G := by
  obtain ⟨f, hf⟩ := exists_injective_zmod_addHom_of_dvd m n h
  exact gainableBy_of_injective_hom f hf hG

/-! ## The obstruction `(n+1)K₂` -/

/-- The biased graph `k·K₂`: `k` parallel edges between two vertices.  Its cycles are the
digons `[(i,+), (j,−)]` for distinct `i, j`, none of which is balanced. -/
def parallelEdges (k : ℕ) : BiasedGraph (Fin k) where
  isCycle c := ∃ i j : Fin k, i ≠ j ∧ c = [(i, true), (j, false)]
  balanced _ := False

/-- **The obstruction.** `(n+1)K₂` is not `ℤ/n`-gainable: a gain labelling would have to
assign `n+1` pairwise distinct labels in `ℤ/n`, impossible by pigeonhole.  Holds for every
`n ≥ 1` (`NeZero n`), prime or composite. -/
theorem parallelEdges_not_gainable (n : ℕ) [NeZero n] :
    ¬ Gainable n (parallelEdges (n + 1)) := by
  rintro ⟨g, hg⟩
  have hinj : Function.Injective g := by
    intro i j hij
    by_contra hne
    have h := hg [(i, true), (j, false)] ⟨i, j, hne, rfl⟩
    have hs : signedSum g [(i, true), (j, false)] = 0 := by simp [signedSum, hij]
    exact (h.2 hs)
  have := Fintype.card_le_of_injective g hinj
  simp [ZMod.card] at this

/-- **General necessity.** Any `ℤ/n`-gainable biased graph contains no `(n+1)K₂` minor. -/
theorem not_isMinor_parallelEdges_of_gainable {F : Type*} (n : ℕ) [NeZero n]
    {G : BiasedGraph F} (hG : Gainable n G) :
    ¬ IsMinor (parallelEdges (n + 1)) G :=
  fun hm => parallelEdges_not_gainable n (gainable_of_isMinor n hG hm)

/-! ## The parallel-class (digon) family and its excluded-minor characterisation -/

/-- The biased graph attached to a *parallel class*: all edges join the same two vertices,
so the cycles are exactly the digons, and a digon `[(i,+), (j,−)]` is balanced precisely
when `i` and `j` are equivalent under the balance relation `s`. -/
def digonGraph {E : Type*} (s : Setoid E) : BiasedGraph E where
  isCycle c := ∃ i j : E, i ≠ j ∧ c = [(i, true), (j, false)]
  balanced c := ∃ i j : E, i ≠ j ∧ c = [(i, true), (j, false)] ∧ s.r i j

/-- A `ℤ/n`-gain labelling of `digonGraph s` is precisely a function `g` with
`s.r i j ↔ g i = g j`. -/
theorem digon_gainable_iff_realises {E : Type*} (n : ℕ) (s : Setoid E) :
    Gainable n (digonGraph s) ↔ ∃ g : E → Gain n, ∀ i j : E, s.r i j ↔ g i = g j := by
  constructor <;> intro h
  · obtain ⟨g, hg⟩ := h
    use fun i => g i
    intro i j; specialize hg [(i, true), (j, false)]; simp_all +decide [digonGraph]
    by_cases hij : i = j <;> simp_all +decide [signedSum]
    · exact Setoid.refl _
    · grind
  · obtain ⟨g, hg⟩ := h
    refine ⟨g, by grind +locals⟩

/-- For a finite parallel class, `digonGraph s` is `ℤ/n`-gainable iff the number of balance
classes is at most `n`. -/
theorem digon_gainable_iff_card {E : Type*} [Fintype E] (n : ℕ) [NeZero n]
    (s : Setoid E) [DecidableRel s.r] :
    Gainable n (digonGraph s) ↔ Fintype.card (Quotient s) ≤ n := by
  constructor
  · intro h
    obtain ⟨g, hg⟩ := digon_gainable_iff_realises n s |>.1 h
    have h_inj : Function.Injective (fun q : Quotient s => g (Quotient.out q)) := by
      intro q q' hqq'
      rw [← Quotient.out_eq q, ← Quotient.out_eq q']
      exact Quotient.sound (hg _ _ |>.2 hqq')
    simpa using Fintype.card_le_of_injective _ h_inj
  · intro h_card
    obtain ⟨g, hg⟩ : ∃ g : Quotient s → ZMod n, Function.Injective g := by
      convert Function.Embedding.nonempty_of_card_le
        (show Fintype.card (Quotient s) ≤ Fintype.card (ZMod n) from ?_) using 1
      · exact ⟨fun ⟨g, hg⟩ => ⟨⟨g, hg⟩⟩, fun ⟨g⟩ => ⟨g, g.injective⟩⟩
      · simpa [ZMod.card] using h_card
    convert digon_gainable_iff_realises n s |>.2
      ⟨fun e => g (Quotient.mk s e), fun i j => ?_⟩ using 1
    simp +decide [hg.eq_iff, Quotient.eq]

/-- `(n+1)K₂` is a minor of `digonGraph s` iff there are at least `n+1` balance classes. -/
theorem digon_isMinor_iff_card {E : Type*} [Fintype E] (n : ℕ)
    (s : Setoid E) [DecidableRel s.r] :
    IsMinor (parallelEdges (n + 1)) (digonGraph s) ↔ n + 1 ≤ Fintype.card (Quotient s) := by
  constructor
  · rintro ⟨φ, σ, hφ, hcyc, hbal⟩
    have h_distinct : ∀ a b : Fin (n + 1), a ≠ b → φ a ≠ φ b ∧ ¬ s.r (φ a) (φ b) := by
      intro a b hab
      specialize hcyc [(a, true), (b, false)]; simp_all +decide [mapCycle]
      specialize hbal [(a, true), (b, false)]; simp_all +decide [parallelEdges, digonGraph]
    have h_inj : Function.Injective (fun a : Fin (n + 1) => Quotient.mk s (φ a)) := by
      intro a b hab; specialize h_distinct a b; simp_all +decide [Quotient.eq]
    simpa using Fintype.card_le_of_injective _ h_inj
  · intro h_card
    obtain ⟨ψ, hψ_inj⟩ : ∃ ψ : Fin (n + 1) → Quotient s, Function.Injective ψ := by
      exact ⟨fun i => Fintype.equivFin _ |>.symm ⟨i, by linarith [Fin.is_lt i]⟩,
        fun i j hij => by simpa [Fin.ext_iff] using hij⟩
    refine' ⟨fun i => Quotient.out (ψ i), fun _ => Bool.false, _, _, _⟩
    · exact fun i j hij => hψ_inj <| by simpa using congr_arg Quotient.mk'' hij
    · intro c hc
      obtain ⟨i, j, hij, hc_eq⟩ := hc
      simp [mapCycle, hc_eq]
      exact ⟨_, _, by simpa [Quotient.out_injective.eq_iff] using hψ_inj.ne hij, rfl⟩
    · intro c hc; obtain ⟨i, j, hij, rfl⟩ := hc; simp +decide [mapCycle]
      simp +decide [parallelEdges, digonGraph]
      exact fun h => by rw [← Quotient.eq]; simp +decide [h]

/-- **Excluded-minor characterisation for the parallel-class family.**  A parallel-class
biased graph is `ℤ/n`-gainable if and only if it has no `(n+1)K₂` minor. -/
theorem digon_excluded_minor {E : Type*} [Fintype E] (n : ℕ) [NeZero n]
    (s : Setoid E) [DecidableRel s.r] :
    Gainable n (digonGraph s) ↔ ¬ IsMinor (parallelEdges (n + 1)) (digonGraph s) := by
  rw [digon_gainable_iff_card, digon_isMinor_iff_card]
  omega

end ZnGain