# Retrocausal Heyting Algebras and the CPT Origin of Time-Reversed Logic

## Abstract

We introduce **retrocausal Heyting algebras**: Heyting algebras equipped with an order-reversing involution `rev` modeling an arrow of implication that runs backward through time. From the two defining axioms (involutivity and antitonicity of `rev`) we derive the full De Morgan duality and pole-swap behavior, with no additional lattice hypotheses. We then establish three structural results. (1) The **law of excluded middle (LEM)** fails in any genuinely intuitionistic (non-Boolean) member of the class; an explicit three-element witness is given. (2) A **temporal excluded middle (TEM)**, namely the double pseudo-complement `(a ⊔ aᶜ)ᶜᶜ = ⊤`, holds in *every* Heyting algebra — a temporal reinterpretation of Glivenko's theorem. (3) LEM is equivalent to double-negation elimination (DNE) pointwise, so any retrocausal logic with a single non-self-dual element is forced to be intuitionistic. Finally, we build a **cross-domain bridge** to constructive quantum field theory: the Osterwalder–Schrader time reflection `θ` (with `θ ∘ θ = id`) of a reflection-positive form, composed with logical negation, is an order-reversing involution on the proposition algebra `Set V`. This makes the propositions of any reflection-positive QFT a retrocausal Heyting algebra whose De Morgan laws and pole swaps are exactly the abstract lemmas, now driven by the physical involution. The capstone theorem certifies that reflection positivity, the retrocausal logical package, and the temporal excluded middle coexist on one structure, exhibiting the **T** of CPT and the logical time-reversal `rev` as a single operator. All results have been formally verified.

**Keywords:** Heyting algebra, intuitionistic logic, excluded middle, Glivenko's theorem, order-reversing involution, De Morgan duality, CPT symmetry, Osterwalder–Schrader reflection positivity, constructive logic.

---

## 1. Introduction

Classical logic is symmetric in a way that conceals a hidden assumption: it treats negation as an involution, so that `¬¬a` and `a` are interchangeable. Intuitionistic logic refuses this identification, retaining only `a ⊢ ¬¬a`. The algebraic shadow of this distinction is the gap between Boolean algebras (`aᶜᶜ = a`) and Heyting algebras (`a ≤ aᶜᶜ`), the latter being the algebraic models of intuitionistic propositional logic.

This paper asks what happens when one equips such a logic with an explicit **time-reversal**: an operation `rev` that turns every implication around. The motivation is twofold. Conceptually, "retrocausal" reasoning — where conclusions constrain premises — is naturally modeled by an order-reversing map, and physical theories with time-reflection symmetry suggest a canonical candidate for it. Mathematically, an order-reversing involution on a bounded lattice is a powerful object: it forces De Morgan duality and pole-swapping for free, and it interacts with the Heyting pseudo-complement in a way that sharply separates the classical and constructive worlds.

Our contributions are:

- **Definition** of a retrocausal Heyting algebra (Section 3) and derivation of its De Morgan and pole-swap laws (Theorems 3.2–3.5).
- **Failure of LEM** in the class, with a minimal explicit model (Theorem 4.1).
- **Temporal excluded middle**: `(a ⊔ aᶜ)ᶜᶜ = ⊤` universally (Theorem 4.2), and the **LEM ↔ DNE** equivalence (Theorem 4.3), yielding *forced intuitionism* (Corollary 4.4).
- **CPT bridge** (Section 5): the OS reflection `θ` composed with negation is an order-reversing involution (Theorems 5.2–5.3), making `Set V` a retrocausal Heyting algebra (Definition 5.4), with the abstract laws transferring verbatim (Theorems 5.5–5.6) and a capstone synthesis (Theorem 5.7).

All statements have been checked in a formal proof assistant; the proofs sketched here mirror the formal arguments.

---

## 2. Preliminaries: Heyting algebras

We recall the minimum needed; all of it is standard.

**Definition 2.1 (Heyting algebra).** A *Heyting algebra* is a bounded lattice `(α, ⊓, ⊔, ⊥, ⊤)` together with a binary operation `⇨` (implication) such that `c ≤ (a ⇨ b)` iff `c ⊓ a ≤ b` for all `a, b, c`. The **pseudo-complement** is `aᶜ := a ⇨ ⊥`.

The defining adjunction yields the following facts, used freely below:

- `a ≤ aᶜᶜ` (double negation introduction), but **not** in general `aᶜᶜ ≤ a`.
- `aᶜᶜᶜ = aᶜ` (triple negation collapses).
- Antitonicity of pseudo-complement: `a ≤ b ⟹ bᶜ ≤ aᶜ`.
- De Morgan inequalities, of which one direction is an equality: `(a ⊔ b)ᶜ = aᶜ ⊓ bᶜ`.

**Definition 2.2 (Boolean).** A Heyting algebra is *Boolean* iff `aᶜᶜ = a` for all `a`, equivalently iff `a ⊔ aᶜ = ⊤` for all `a`.

The smallest non-Boolean Heyting algebra is the **three-element chain** `⊥ < m < ⊤`, with `mᶜ = ⊥` and hence `m ⊔ mᶜ = m ≠ ⊤`. This object will serve as our canonical counterexample.

---

## 3. Retrocausal Heyting algebras

### 3.1 Definition

**Definition 3.1 (Retrocausal Heyting algebra).** A *retrocausal Heyting algebra* on a Heyting algebra `α` is an operation `rev : α → α` together with proofs of:

- **(R1) Involution:** `rev (rev a) = a` for all `a`;
- **(R2) Antitone:** `a ≤ b ⟹ rev b ≤ rev a`.

We call `rev` the *time-reversal*. Intuitively `rev a` is the proposition "`a`, viewed from the reversed temporal direction." (R1) says reversing time is its own inverse; (R2) says reversal flips the direction of every entailment, which is the formal content of "implications flow backward in time."

In the formal development this is the structure
```
structure RetrocausalHeyting (α) [HeytingAlgebra α] where
  rev : α → α
  rev_involutive : Function.Involutive rev
  rev_antitone   : ∀ {a b}, a ≤ b → rev b ≤ rev a
```

### 3.2 Derived duality

An order-reversing involution on a bounded lattice is automatically an *anti-automorphism*: it exchanges the lattice operations and the extremal elements. The proofs are the standard Galois-style arguments.

**Theorem 3.2 (De Morgan, join→meet — `rev_sup`).** `rev (a ⊔ b) = rev a ⊓ rev b`.

*Proof sketch.* Since `a ≤ a ⊔ b` and `b ≤ a ⊔ b`, antitonicity gives `rev (a ⊔ b) ≤ rev a` and `rev (a ⊔ b) ≤ rev b`, so `rev (a ⊔ b) ≤ rev a ⊓ rev b`. Conversely, apply the same reasoning to the involuted elements: `rev a ⊓ rev b ≤ rev a` gives, after applying `rev` and using (R1) twice, `a ≤ rev (rev a ⊓ rev b)`; symmetrically `b ≤ rev (rev a ⊓ rev b)`; hence `a ⊔ b ≤ rev (rev a ⊓ rev b)`, and applying antitone `rev` plus (R1) yields `rev a ⊓ rev b ≤ rev (a ⊔ b)`. Antisymmetry closes it. ∎

**Theorem 3.3 (De Morgan, meet→join — `rev_inf`).** `rev (a ⊓ b) = rev a ⊔ rev b`.

*Proof sketch.* Dual to Theorem 3.2; equivalently apply Theorem 3.2 to `rev a, rev b` and use (R1). ∎

**Theorem 3.4 (Pole swap, bottom — `rev_bot`).** `rev ⊥ = ⊤`.

*Proof sketch.* For all `a`, `⊥ ≤ a`, so by (R2) `rev a ≤ rev ⊥`; thus `rev ⊥` is an upper bound of the image of `rev`. Since `rev` is a bijection (involution), its image is all of `α`, so `rev ⊥` is the greatest element `⊤`. ∎

**Theorem 3.5 (Pole swap, top — `rev_top`).** `rev ⊤ = ⊥`.

*Proof sketch.* Apply `rev` to Theorem 3.4 and use (R1): `⊥ = rev (rev ⊥) = rev ⊤`. ∎

Theorems 3.2–3.5 show that the *entire* De Morgan apparatus is a consequence of (R1)+(R2) alone. No distributivity, no Booleanness, and no special interaction with `⇨` is required. Time-reversal is, structurally, a De Morgan duality.

---

## 4. Excluded middle, temporal excluded middle, and forced intuitionism

### 4.1 LEM fails

**Theorem 4.1 (Failure of excluded middle — `retro_lem_fails`).** There is a retrocausal Heyting algebra and an element `a` with `a ⊔ aᶜ ≠ ⊤`.

*Proof sketch.* Take the three-element chain `C = {⊥ < m < ⊤}`. It is a Heyting algebra with `mᶜ = ⊥`. Equip it with the unique order-reversing involution `rev` swapping `⊥ ↔ ⊤` and fixing `m`; (R1) and (R2) are immediate by case analysis on the three elements. Then `m ⊔ mᶜ = m ⊔ ⊥ = m ≠ ⊤`. ∎

Theorem 4.1 confirms the class is strictly larger than the Boolean one and that genuine indeterminacy ("`m`": neither true nor false) is consistent with a working time-reversal.

### 4.2 The temporal excluded middle

While LEM may fail, its double negation does not.

**Theorem 4.2 (Temporal excluded middle — `temporal_excluded_middle`).** In *every* Heyting algebra, `(a ⊔ aᶜ)ᶜᶜ = ⊤` for all `a`.

*Proof sketch.* It suffices to show `(a ⊔ aᶜ)ᶜ = ⊥`, since `⊥ᶜ = ⊤`. Now `(a ⊔ aᶜ)ᶜ = aᶜ ⊓ aᶜᶜ` by the (always-valid) De Morgan identity `(x ⊔ y)ᶜ = xᶜ ⊓ yᶜ`. But `aᶜ ⊓ aᶜᶜ ≤ aᶜ ⊓ (aᶜ ⇨ ⊥)`... more directly, `aᶜ ⊓ aᶜᶜ = ⊥` because `aᶜᶜ = (aᶜ) ⇨ ⊥`'s defining adjunction gives `aᶜ ⊓ aᶜᶜ ≤ ⊥`. Hence `(a ⊔ aᶜ)ᶜ = ⊥` and `(a ⊔ aᶜ)ᶜᶜ = ⊤`. ∎

This is the lattice form of Glivenko's theorem: a classical tautology becomes an intuitionistic theorem after a double negation. We name it the **temporal** excluded middle because, read through `rev`, the double pseudo-complement is the "there-and-back" temporal closure; it is exactly the part of LEM that is invariant under the reversal. The contrast with Theorem 4.1 is the conceptual core of the paper: the raw disjunction is contingent, its time-symmetric closure is necessary.

### 4.3 LEM is equivalent to DNE; intuitionism is forced

**Theorem 4.3 (LEM ↔ DNE — `lem_iff_dne`).** For an element `a` of a Heyting algebra, `a ⊔ aᶜ = ⊤` if and only if `aᶜᶜ = a`.

*Proof sketch.* (⇒) Suppose `a ⊔ aᶜ = ⊤`. Always `a ≤ aᶜᶜ`. For the reverse, meet both sides of `a ⊔ aᶜ = ⊤` with `aᶜᶜ`: `aᶜᶜ = aᶜᶜ ⊓ (a ⊔ aᶜ) = (aᶜᶜ ⊓ a) ⊔ (aᶜᶜ ⊓ aᶜ)` by distributivity. The second meet is `⊥` (Theorem 4.2's key fact `aᶜ ⊓ aᶜᶜ = ⊥`), and the first is `≤ a`; hence `aᶜᶜ ≤ a`, giving equality. (⇐) Suppose `aᶜᶜ = a`. Then `a ⊔ aᶜ = aᶜᶜ ⊔ aᶜ`, and by De Morgan `(aᶜᶜ ⊔ aᶜ)ᶜ = aᶜᶜᶜ ⊓ aᶜᶜ = aᶜ ⊓ aᶜᶜ = ⊥` (using `aᶜᶜᶜ = aᶜ`), so `a ⊔ aᶜ = ⊥ᶜ = ⊤`. ∎

**Corollary 4.4 (Forced intuitionism — `lem_fails_of_dne_fails`).** If `aᶜᶜ ≠ a` for some `a`, then `a ⊔ aᶜ ≠ ⊤` at that `a`. Equivalently, any non-Boolean retrocausal Heyting algebra fails LEM; there is no non-trivial *classical* retrocausal logic.

*Proof.* Contrapositive of the (⇒) direction of Theorem 4.3. ∎

Corollary 4.4 is the promised structural verdict: because Boolean-ness is precisely the universal validity of `aᶜᶜ = a`, a retrocausal Heyting algebra that is interesting (has even one non-self-dual element under double negation) cannot satisfy excluded middle. Retrocausality and constructivity arrive together.

---

## 5. The CPT bridge: time reflection as logical reversal

We now exhibit a canonical, physically motivated source of the involution `rev`.

### 5.1 Reflection-positive forms

**Definition 5.1 (Reflection-positive form).** Let `V` be a real vector space. A *reflection-positive form* is a bilinear, symmetric `B : V × V → ℝ` together with an operator `θ : V → V` such that:

- `θ` is an **involution**: `θ (θ v) = v`;
- `θ` is **`B`-self-adjoint**: `B (θ u) v = B u (θ v)`;
- **Reflection positivity**: `0 ≤ B (θ v) v` for all `v`.

This axiomatizes the Osterwalder–Schrader positivity condition of Euclidean quantum field theory; `θ` is the Euclidean time reflection — the **T** of CPT — and the positivity bound is what guarantees a unitary, positive-norm quantum theory upon reconstruction. The induced *physical inner product* `⟨u, v⟩ := B (θ u) v` is symmetric and positive semi-definite, precisely by self-adjointness and reflection positivity.

### 5.2 The CPT reversal connective

The propositions of the theory are subsets `S ⊆ V` ("the field configuration lies in `S`"), forming the Boolean — hence Heyting — algebra `Set V`, with `⊓ = ∩`, `⊔ = ∪`, `Sᶜ` the set complement, `⊥ = ∅`, `⊤ = V`.

**Definition 5.2 (CPT reversal — `cptReversal`).** For a reflection-positive form `R = (B, θ)`, define
```
cptReversal R S := θ⁻¹(Sᶜ).
```
This is the composite **C ∘ T**: first the logical analogue of charge conjugation (complement `(·)ᶜ`), then the physical time reflection (preimage under `θ`).

**Theorem 5.2 (Involutivity — `cptReversal_involutive`).** `cptReversal R` is an involution.

*Proof sketch.* `cptReversal R (cptReversal R S) = θ⁻¹((θ⁻¹(Sᶜ))ᶜ) = θ⁻¹(θ⁻¹(Sᶜᶜ)) = (θ ∘ θ)⁻¹(S)`, using `preimage` commutes with complement and `Sᶜᶜ = S`. Since `θ ∘ θ = id` (the physical involution), `(θ ∘ θ)⁻¹(S) = S`. ∎

**Theorem 5.3 (Antitonicity — `cptReversal_antitone`).** If `S ⊆ T` then `cptReversal R T ⊆ cptReversal R S`.

*Proof sketch.* `S ⊆ T ⟹ Tᶜ ⊆ Sᶜ ⟹ θ⁻¹(Tᶜ) ⊆ θ⁻¹(Sᶜ)`, i.e. preimage is monotone in its set argument. ∎

Theorems 5.2 and 5.3 are exactly axioms (R1) and (R2). The physical content used is *only* `θ ∘ θ = id`; reflection positivity itself is not needed for the logical structure (it re-enters in the synthesis below as the genuinely physical half).

### 5.3 The retrocausal logic of a QFT

**Definition 5.4 (`cptRetrocausal`).** The data of Theorems 5.2–5.3 assemble `Set V` into a retrocausal Heyting algebra with `rev := cptReversal R`.

Consequently every abstract theorem of Section 3 specializes, with no new lattice work:

**Theorem 5.5 (De Morgan for CPT — `cpt_rev_sup`, `cpt_rev_inf`).**
```
cptReversal R (S ⊔ T) = cptReversal R S ⊓ cptReversal R T,
cptReversal R (S ⊓ T) = cptReversal R S ⊔ cptReversal R T.
```
*Proof.* Instances of Theorems 3.2–3.3 applied to `cptRetrocausal R`. ∎

**Theorem 5.6 (Pole swap for CPT — `cpt_rev_swaps_poles`).** `cptReversal R ⊥ = ⊤` and `cptReversal R ⊤ = ⊥`.

*Proof.* Instances of Theorems 3.4–3.5. ∎

### 5.4 Capstone

**Theorem 5.7 (CPT yields retrocausal logic — `cpt_yields_retrocausal_logic`).** For every reflection-positive form `R` on `V`, all of the following hold simultaneously:

1. **(Physics)** `0 ≤ B (θ v) v` for all `v` (reflection positivity);
2. **(Logic, involution)** `cptReversal R` is an involution;
3. **(Logic, De Morgan)** `cptReversal R (S ⊔ T) = cptReversal R S ⊓ cptReversal R T` for all `S, T`;
4. **(Logic, pole)** `cptReversal R ⊥ = ⊤`;
5. **(Logic, TEM)** `(P ⊔ Pᶜ)ᶜᶜ = ⊤` for every proposition `P`.

*Proof.* (1) is `R.reflection_pos`; (2) is Theorem 5.2; (3) is Theorem 5.5; (4) is Theorem 5.6; (5) is Theorem 4.2 instantiated at `Set V`. ∎

The theorem witnesses that the same operator `θ` is simultaneously the QFT time-reflection and the logical reversal `rev`. Neither half is derivable without the other domain's structure: clause (1) requires the physical positivity axiom, clauses (2)–(4) require the logical anti-automorphism lemmas applied to a structure built *from* `θ`. In this precise sense, **CPT symmetry and retrocausal (intuitionistic-style) logic are two faces of one involution.**

**Remark 5.8 (On classicality of the carrier).** `Set V` is Boolean, so on this carrier LEM also holds; the involution transfers from physics regardless of the carrier's classicality, but the *failure* of LEM does not transfer — it requires a non-Boolean carrier such as the three-element model of Theorem 4.1. The bridge therefore isolates the CPT *origin of the involution*, not the source of non-classicality. This separation is deliberate and is what keeps the correspondence rigorous rather than merely evocative.

---

## 6. Algorithms

The development is constructive enough to be executed on finite models. We summarize the two algorithmic kernels (full code in `demo.py`).

**Algorithm A (De Morgan / involution verifier on a finite Heyting algebra).** Given the order relation of a finite Heyting algebra as a table, compute `⊓`, `⊔`, pseudo-complement `aᶜ = ⋁{x : x ⊓ a = ⊥}`, and a candidate order-reversing involution `rev`. Verify (R1), (R2), the four duality laws, the failure points of LEM, and the universal validity of TEM. Complexity: `O(n³)` for the meet/join tables on `n` elements, `O(n²)` per law check.

**Algorithm B (CPT reversal on a finite configuration space).** Given a finite configuration set `V`, an involution `θ : V → V`, and propositions as bitmasks, compute `cptReversal S = θ⁻¹(Sᶜ)` and check involutivity, antitonicity, De Morgan, and pole-swap directly. Complexity: `O(|V|)` per proposition for the reversal, `O(2^{|V|})` to exhaust all propositions in a brute-force law check.

---

## 7. Applications

**Constructive cryptography.** Intuitionistic logic is the logic of witness-producing proofs; security reductions that merely refute nonexistence are useless operationally. The LEM↔DNE equivalence (Theorem 4.3) and the temporal excluded middle (Theorem 4.2) are the lattice-level shadow of the double-negation (Gödel–Gentzen) translation that converts classical existence arguments into constructive ones. A retrocausal involution that exchanges complementary roles (secret/known, encrypt/decrypt, challenge/response) while preserving De Morgan structure offers a unified algebraic vocabulary for time-symmetric protocol analysis; the TEM is the conserved component of an adversary's certain knowledge under temporal reversal.

**Foundations of QFT.** Theorem 5.7 gives a clean, axiom-light statement that reflection positivity carries an intrinsic logical anti-automorphism. This reframes CPT not only as a spacetime/charge symmetry but as a duality on the propositional content of the theory.

**Many-valued and temporal logics.** The three-element model is the minimal Łukasiewicz/Gödel chain; retrocausal structure on such chains gives toy temporal logics in which "undetermined now" resolves to "determined under time-symmetric closure."

---

## 8. Discussion

The economy of the results is notable: the entire De Morgan and pole-swap package follows from two axioms, and the dividing line between classical and constructive behavior collapses onto the single condition `aᶜᶜ = a`. The bridge then shows the abstraction is not vacuous — a standard object of mathematical physics realizes it canonically.

The honest limitation, made explicit in Remark 5.8, is that the QFT proposition carrier `Set V` is Boolean, so the bridge transfers the involution but not the non-classicality. To obtain a QFT-derived model in which LEM genuinely fails one must replace `Set V` by a non-Boolean algebra of propositions — for instance an algebra of *regular open* sets, of `θ`-invariant measurable sets modulo null sets, or of observable subspaces in a non-distributive (quantum-logical) lattice. This is the natural next target.

---

## 9. Future work

The cycle suggests three concrete conjectures.

**Conjecture 1 (Retrocausal Glivenko transfer).** A formula `φ` is provable in a retrocausal intuitionistic sequent calculus with a time-reversal involution iff its CPT double-negation `(φ ⊔ φᶜ)ᶜᶜ`-closure is classically provable, with `rev` acting as a provability-preserving De Morgan duality on the Lindenbaum–Tarski algebra. The temporal excluded middle (Theorem 4.2) shows the doubly negated LEM is a theorem rather than an axiom, so Glivenko's theorem should lift, with `rev` permuting De Morgan dual pairs.

**Conjecture 2 (Fixed points are a Boolean subalgebra).** For a reflection-positive QFT, the propositions fixed by CPT reversal, `{S : cptReversal R S = S}`, form a sublattice on which LEM is restored — a maximal classical island inside the retrocausal logic. The involution gives a `ℤ/2` action; the fixed-point set of an antitone involution is closed under the De Morgan-swapped operations, forcing self-duality and hence Boolean behavior.

**Conjecture 3 (LEM-failure obstructs Boolean carriers).** Every retrocausal Heyting algebra failing LEM at even one element is non-Boolean, and the `Fin (n+3)` chains give an infinite family of LEM-failing retrocausal algebras with strictly growing failure sets. Corollary 4.4 ties LEM-failure to DNE-failure; the explicit three-element model realizes one failure point with a working time-reversal.

---

## 10. Conclusion

We defined retrocausal Heyting algebras, derived their full duality from two axioms, located the precise boundary at which excluded middle dies (and the double-negated remnant that always survives), proved that any non-trivial retrocausal logic is forced to be intuitionistic, and exhibited the Osterwalder–Schrader time reflection of reflection-positive quantum field theory as a canonical realization of the logical time-reversal. The capstone theorem certifies, on a single structure, the coexistence of physical reflection positivity, the retrocausal De Morgan/pole-swap package, and the temporal excluded middle — identifying the **T** of CPT with the `rev` of logic.
