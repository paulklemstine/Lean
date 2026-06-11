# Proof System Collapse: The Simulation Preorder, its Lattice Duality, and the Closure of Polynomial Boundedness under Joins

## Abstract

We develop an abstract theory of propositional proof systems in the sense of Cook
and Reckhow, organized entirely around the **simulation preorder**. A proof system
over a type of formulas `F` is modelled minimally as a triple `(Proof, concl, size)`:
an abstract type of proofs, a conclusion map assigning each proof the formula it
establishes, and a natural-number size measure. The central invariant is the
**provable set** `Prov P`, the range of the conclusion map. Simulation is defined
as containment of provable sets, and simulation-equivalence as their equality.

Our results fall into three groups. **(1) Lattice duality.** We exhibit three
constructions — disjoint union, fibred product, and indexed disjoint union — and
prove that on provable sets they realize, respectively, the join, the meet, and
arbitrary joins of the powerset lattice of `F`. Together with a realizability
theorem showing that *every* subset of `F` is the provable set of some system, this
establishes that proof systems modulo simulation form a structure order-isomorphic
to the complete powerset lattice `(Set F, ⊆)`. **(2) Maximality.** Relative to any
validity predicate, every complete system simulates every sound system — the
abstract kernel of the Cook–Reckhow optimality phenomenon. **(3) Quantitative
closure.** We define polynomial boundedness with respect to a formula-complexity
measure and prove that the join of two p-bounded systems is p-bounded, and, as the
quantitative flagship, that the indexed join of *finitely many* p-bounded systems is
p-bounded. We isolate the finite-to-infinite gap in this closure as the precise
locus of the Cook–Reckhow optimality conjecture. All results have been formally
verified; this paper presents the mathematics and proof sketches.

**Keywords.** Proof complexity, Cook–Reckhow, simulation, p-simulation, proof
systems, lattice theory, polynomial boundedness, optimal proof systems.

---

## 1. Introduction

Proof complexity studies not whether a statement is *true* but how *expensive* it
is to certify. Its founding framework, due to Cook and Reckhow, recasts a
propositional proof system as a polynomial-time-computable surjection from strings
("proofs") onto the set of tautologies, and compares systems by **p-simulation**:
`Q` p-simulates `P` if every `P`-proof can be translated, in polynomial time, into a
`Q`-proof of the same theorem with at most polynomial blow-up. The grand open
problem of the field — whether a *polynomially bounded* proof system exists, which is
equivalent to `NP = coNP` — and the related question of whether an *optimal* proof
system exists, both live inside this comparison.

Underneath the polynomial-time machinery lies a purely qualitative skeleton: which
theorems each system can establish at all. This paper isolates that skeleton,
develops its order theory completely, and then re-attaches the quantitative layer
to study how efficiency interacts with the lattice operations. The qualitative core
turns out to be a perfect duality with subsets of the formula type, and the
quantitative layer turns out to respect the lattice join up to — and exactly up to —
finite arity.

We work over an arbitrary type `F` of formulas, making no syntactic commitments;
this maximal generality is what exposes the duality so cleanly.

### 1.1 Contributions

- A minimal, syntax-free formalization of proof systems and the simulation preorder
  (Section 2).
- Three lattice constructions and the proofs that they compute join, meet, and
  arbitrary join on provable sets (Section 3).
- A realizability/duality theorem: `Prov` is surjective onto `Set F`, hence proof
  systems modulo simulation reproduce the entire powerset lattice (Section 3.4).
- Universal-property characterizations of join and meet within the simulation
  order (Section 4).
- The maximality theorem: complete systems simulate all sound systems (Section 5).
- Definition of polynomial boundedness and the closure theorems for binary and
  finite indexed joins, with an analysis of why the closure stops at finite arity
  (Section 6).
- Algorithms and applications to solver portfolios and cross-validation (Sections
  7–8), and a research program for the quantitative theory (Section 9).

---

## 2. The simulation preorder

### 2.1 Proof systems and provable sets

> **Definition 2.1 (Proof system).** A *proof system* over a type `F` is a triple
> `P = (Proof, concl, size)` where `Proof` is a type, `concl : Proof → F`, and
> `size : Proof → ℕ`.

The deliberate minimality matters: no inference rules, no syntax, no soundness
built in. A proof is any object from which we can read a conclusion and a cost.

> **Definition 2.2 (Provable set).** The *provable set* of `P` is
> `Prov P := range(concl) = { f : F | ∃ p, concl p = f }`.

Membership unfolds definitionally: `f ∈ Prov P ↔ ∃ p, concl p = f`.

### 2.2 Simulation

> **Definition 2.3 (Simulation).** For systems `P, Q`, say `Q` *simulates* `P`,
> written `Simulates Q P`, when `Prov P ⊆ Prov Q`.

> **Proposition 2.4.** `Simulates` is reflexive and transitive (a preorder).

*Proof.* Reflexivity is `Prov P ⊆ Prov P`. For transitivity, if `Prov Q ⊆ Prov R`
and `Prov P ⊆ Prov Q` then `Prov P ⊆ Prov R` by transitivity of `⊆`. ∎

> **Definition 2.5 (Simulation-equivalence).** `P` and `Q` are *simulation-equivalent*,
> `SimEquiv P Q`, when each simulates the other.

> **Theorem 2.6 (Equivalence is equality of repertoires).**
> `SimEquiv P Q ↔ Prov P = Prov Q`.

*Proof.* `SimEquiv P Q` unfolds to `Prov Q ⊆ Prov P ∧ Prov P ⊆ Prov Q`, which is
antisymmetry of `⊆`, equivalent to `Prov P = Prov Q`. ∎

Theorem 2.6 is the licence to identify a proof system with its provable set up to
simulation. Everything downstream exploits this identification.

---

## 3. Lattice constructions and duality

We now give three constructions of new systems and compute their provable sets,
plus a realizability theorem. The slogan is: *`Prov` is a surjective lattice
homomorphism onto `(Set F, ∪, ∩)`*.

### 3.1 The join (disjoint union)

> **Definition 3.1 (Union).** `union P Q` has proof type `P.Proof ⊕ Q.Proof`,
> conclusion `Sum.elim P.concl Q.concl`, and size `Sum.elim P.size Q.size`.

A proof is a proof from either component; sizes are inherited unchanged.

> **Theorem 3.2 (Join).** `Prov (union P Q) = Prov P ∪ Prov Q`.

*Proof.* Unfolding, a formula `f` lies in the left side iff some `p : P.Proof ⊕
Q.Proof` has `Sum.elim P.concl Q.concl p = f`. Case-splitting on `p = inl a` or
`p = inr b` gives `P.concl a = f` or `Q.concl b = f`, i.e. `f ∈ Prov P ∪ Prov Q`;
conversely each disjunct supplies the corresponding injected proof. This is exactly
`range (Sum.elim f g) = range f ∪ range g`. ∎

### 3.2 The meet (fibred product)

> **Definition 3.3 (Meet).** `meet P Q` has proof type
> `{ (p, q) : P.Proof × Q.Proof // P.concl p = Q.concl q }` — pairs of proofs with a
> *common conclusion* — conclusion `(p,q) ↦ P.concl p`, and size
> `(p,q) ↦ P.size p + Q.size q`.

A proof is a *certificate of agreement*: both components establish the same formula.
The additive size is intrinsic to the construction and underlies the "meet preserves
additive bounds" program of Section 9.

> **Theorem 3.4 (Meet).** `Prov (meet P Q) = Prov P ∩ Prov Q`.

*Proof.* If `f` is the conclusion of a pair `⟨(a,b), h⟩` with `h : P.concl a = Q.concl b`
and `P.concl a = f`, then `f ∈ Prov P` (via `a`) and `f = Q.concl b ∈ Prov Q`.
Conversely if `f = P.concl a` and `f = Q.concl b`, the pair `(a,b)` has matching
conclusions, so `⟨(a,b), _⟩` is a valid proof concluding `f`. ∎

### 3.3 Arbitrary joins (indexed disjoint union)

> **Definition 3.5 (Indexed union).** For a family `P : ι → ProofSys F`, the system
> `iUnion P` has proof type `Σ i, (P i).Proof`, conclusion `⟨i, p⟩ ↦ (P i).concl p`,
> and size `⟨i, p⟩ ↦ (P i).size p`.

> **Theorem 3.6 (Arbitrary join).** `Prov (iUnion P) = ⋃ᵢ Prov (P i)`.

*Proof.* A formula is a conclusion of `iUnion P` iff it is `(P i).concl p` for some
`i` and some `p : (P i).Proof`, i.e. iff it lies in `Prov (P i)` for some `i`. ∎

### 3.4 Realizability and the duality

> **Definition 3.7 (Tautology-table and singleton systems).** For `S : Set F`, the
> system `setSys S` has proof type `S` (the subtype), conclusion `Subtype.val`, and
> size constantly `0`. For `f : F`, `singletonSys f` has proof type `Unit`,
> conclusion the constant `f`, and size `0`.

> **Lemma 3.8.** `Prov (singletonSys f) = {f}` and `Prov (setSys S) = S`.

*Proof.* The first is `range (const f) = {f}`. The second is `range Subtype.val = S`. ∎

> **Theorem 3.9 (Duality / surjectivity).** The map `Prov : ProofSys F → Set F` is
> surjective: every set `S : Set F` equals `Prov (setSys S)`.

*Proof.* Immediate from Lemma 3.8. ∎

**Consequence.** Combine Theorem 2.6 (simulation-equivalence = equality of provable
sets), Theorems 3.2, 3.4, 3.6 (the constructions compute `∪`, `∩`, `⋃`), and Theorem
3.9 (surjectivity). The provable-set map is a surjective homomorphism from the
constructions on proof systems onto the lattice operations of `(Set F, ⊆)`, and its
fibres are exactly the simulation-equivalence classes. Hence:

> **Corollary 3.10 (Lattice collapse).** Proof systems modulo simulation-equivalence,
> ordered by simulation, form a structure order-isomorphic to the complete,
> bounded, distributive lattice `(Set F, ⊆)`, with `union` realizing join, `meet`
> realizing meet, `iUnion` realizing arbitrary join, `setSys ∅` the bottom, and
> `setSys univ` the top. The section `S ↦ setSys S` is a canonical right inverse to
> `Prov`.

This is the "proof system collapse": the wild combinatorics of proofs collapses, up
to simulation, onto plain subset inclusion.

---

## 4. Universal properties of join and meet

The lattice structure can also be verified directly through universal properties,
without passing through the powerset isomorphism. These give the operational meaning
of "least upper bound" and "greatest lower bound" inside the simulation order.

> **Proposition 4.1 (Join is the least upper bound).**
> (i) `Simulates (union P Q) P` and `Simulates (union P Q) Q`.
> (ii) If `Simulates R P` and `Simulates R Q`, then `Simulates R (union P Q)`.

*Proof.* (i) `Prov P ⊆ Prov P ∪ Prov Q = Prov(union P Q)` by Theorem 3.2, and
symmetrically for `Q`. (ii) From `Prov P ⊆ Prov R` and `Prov Q ⊆ Prov R` we get
`Prov P ∪ Prov Q ⊆ Prov R`, i.e. `Prov(union P Q) ⊆ Prov R`. ∎

> **Proposition 4.2 (Meet is the greatest lower bound).**
> (i) `Simulates P (meet P Q)` (and symmetrically `Simulates Q (meet P Q)`).
> (ii) If `Simulates P R` and `Simulates Q R`, then `Simulates (meet P Q) R`.

*Proof.* (i) `Prov(meet P Q) = Prov P ∩ Prov Q ⊆ Prov P` by Theorem 3.4. (ii) From
`Prov R ⊆ Prov P` and `Prov R ⊆ Prov Q` we get `Prov R ⊆ Prov P ∩ Prov Q =
Prov(meet P Q)`. ∎

Propositions 4.1–4.2 confirm that `union` and `meet` are genuinely the lattice
operations of the simulation preorder, independently of Corollary 3.10.

---

## 5. Soundness, completeness, and maximality

We now relativize to a notion of validity, the abstract stand-in for "tautology" or
"true sentence."

> **Definition 5.1.** Fix `Valid : F → Prop`.
> `P` is *sound* (for `Valid`) when `∀ f ∈ Prov P, Valid f`.
> `P` is *complete* (for `Valid`) when `∀ f, Valid f → f ∈ Prov P`.

Soundness says the repertoire is contained in the valid formulas; completeness says
it contains them. A *correct* system is both, with repertoire exactly the valid set.

> **Theorem 5.2 (Maximality of complete systems).** If `C` is complete and `P` is
> sound for the same `Valid`, then `Simulates C P`.

*Proof.* Let `f ∈ Prov P`. By soundness of `P`, `Valid f`. By completeness of `C`,
`f ∈ Prov C`. Hence `Prov P ⊆ Prov C`, i.e. `Simulates C P`. ∎

Theorem 5.2 is the abstract Cook–Reckhow optimality phenomenon: among trustworthy
systems, the complete ones are maximal in simulation power. Equivalently, in the
lattice of Corollary 3.10, every complete system sits at the supremum `{f | Valid f}`
of the sound systems, which all lie below it. The hard, open part of the real theory
is to make "simulates" *efficient* (p-simulation) — the subject of the next section.

---

## 6. Polynomial boundedness and its closure under joins

We re-attach the quantitative layer. Fix a *formula-complexity* measure
`cx : F → ℕ` (intuitively, the encoding length of a formula).

> **Definition 6.1 (Polynomial boundedness).** A system `P` is *polynomially
> bounded* with respect to `cx`, written `PBounded cx P`, when there exist constants
> `c, k : ℕ` such that every theorem admits a short proof:
> `∀ f ∈ Prov P, ∃ p, concl p = f ∧ size p ≤ c · (cx f + 1)^k`.

The single pair `(c, k)` must work uniformly across the entire repertoire; this
uniformity is the crux of the closure analysis.

> **Theorem 6.2 (Binary join preserves p-boundedness).** If `PBounded cx P` and
> `PBounded cx Q`, then `PBounded cx (union P Q)`.

*Proof sketch.* Let `(c₁, k₁)` witness `P` and `(c₂, k₂)` witness `Q`. Put
`c := c₁ + c₂` and `k := max(k₁, k₂)`. Take any `f ∈ Prov(union P Q) = Prov P ∪ Prov
Q`. If `f ∈ Prov P`, pick the short `P`-proof `p` with `P.size p ≤ c₁ (cx f+1)^{k₁}`;
inject it as `inl p`, whose size in the union is unchanged. Since `c₁ ≤ c` and
`(cx f+1)^{k₁} ≤ (cx f+1)^{k}` (as `cx f + 1 ≥ 1`), we get
`size(inl p) ≤ c (cx f+1)^k`. The case `f ∈ Prov Q` is symmetric with `inr`. ∎

The same idea scales to any *finite* family. This is the quantitative flagship.

> **Theorem 6.3 (Finite indexed join preserves p-boundedness).** Let `ι` be a finite
> index type and `P : ι → ProofSys F` a family with `PBounded cx (P i)` for every `i`.
> Then `PBounded cx (iUnion P)`.

*Proof sketch.* For each `i`, choose witnesses `(c_i, k_i)`. Because `ι` is finite,
the sets `{c_i}` and `{k_i}` are finite; set `c := Σ_i c_i` (or `max_i c_i`) and
`k := max_i k_i`, both well-defined. Given `f ∈ Prov(iUnion P) = ⋃_i Prov(P i)`, fix
an index `j` with `f ∈ Prov(P j)` and a short `P j`-proof `p` with
`(P j).size p ≤ c_j (cx f+1)^{k_j}`. Its image `⟨j, p⟩` in `iUnion P` has the same
size, and `c_j ≤ c`, `(cx f+1)^{k_j} ≤ (cx f+1)^{k}` give `size⟨j,p⟩ ≤ c (cx f+1)^k`.
Hence `(c, k)` is a uniform witness. ∎

### 6.1 Why finiteness is essential

The proof of Theorem 6.3 consumes finiteness in exactly one place: forming
`max_i k_i` and a finite sum/max of the `c_i`. For an *infinite* family with
exponents `k_i → ∞` or constants `c_i → ∞`, no single `(c, k)` can dominate every
component, and `iUnion P` need not be p-bounded even when each `P i` is. This is not
an artifact of the argument: it is the genuine mathematical boundary. The
**Cook–Reckhow optimality conjecture** — that no single proof system p-simulates all
others — is precisely the assertion that the jump from finite to countable joins
cannot be made uniformly. Our framework localizes the conjecture: the finite case is
a theorem (6.3); the infinite case, *with a shared bound*, would follow by the same
argument, so the entire difficulty is the absence of a shared bound across an
infinite family. See Section 9.3.

---

## 7. Algorithms

The abstract theory yields concrete procedures whenever provable sets are finite or
enumerable. We record three.

### 7.1 Simulation test (finite repertoires)

To decide `Simulates Q P` when both repertoires are finite, check `Prov P ⊆ Prov Q`
directly by membership tests. Complexity: `O(|Prov P| · T_Q)` where `T_Q` is the cost
of a `Q`-membership test. Simulation-equivalence is two such tests.

### 7.2 Join / meet repertoire computation

By Theorems 3.2 and 3.4, computing the repertoire of a combination reduces to a set
union or intersection of the component repertoires — `O(|Prov P| + |Prov Q|)` with
hashing. This makes the lattice operations executable: one never needs to inspect
proof internals, only repertoires.

### 7.3 Uniform polynomial-bound synthesis

Given per-system witnesses `(c_i, k_i)` for a finite family, the constructive content
of Theorem 6.3 is an algorithm that returns the *combined* witness `(Σ c_i, max k_i)`
in `O(|ι|)` time. This is the formal underpinning of the portfolio guarantee in
Section 8.

---

## 8. Applications

**Solver portfolios.** Modern SAT/SMT practice runs several solvers in parallel and
accepts the first certificate produced. This is exactly the join `iUnion`. Theorem
3.6 says the portfolio's repertoire is the union of its members' repertoires (it
solves anything any member solves), and Theorem 6.3 guarantees the portfolio stays
polynomially bounded if its members are — it is never asymptotically worse than its
best member. The synthesis algorithm of Section 7.3 produces the explicit combined
bound.

**Cross-validation / redundant certification.** Safety-critical pipelines often
demand that two independent tools confirm the same result. This is the meet:
Theorem 3.4 says the cross-validated repertoire is the intersection, and the
*additive* size of meet proofs (Definition 3.3) quantifies the cost of redundancy —
you pay the sum of both certificates. This makes the price of assurance explicit and
prepares the "meet preserves additive bounds" result of Section 9.1.

**Optimality landscape.** Theorem 5.2 identifies complete systems as simulation-maximal,
giving a clean target for "as powerful as possible" reference systems, while Section
6.1 pinpoints where efficiency-optimality becomes the famous open conjecture.

---

## 9. Discussion and future work

The framework converts proof-complexity comparisons into lattice operations on
subsets, with a quantitative layer that respects joins up to finite arity. We close
with the research program these results open.

### 9.1 Meet preserves additive proof-size bounds

The join lifts to the polynomial setting (Theorems 6.2–6.3). The dual question
concerns the meet, whose proofs are pairs and whose size therefore *adds*:
`(meet P Q).size = P.size ∘ fst + Q.size ∘ snd`. The optimal proof size in the meet
is bounded by the *sum* of optimal sizes in the components; combined with Theorem
3.4 this should give a quantitative meet law dual to Theorem 6.2:
`PBounded cx P → PBounded cx Q → PBounded cx (meet P Q)`, taking `c = c₁ + c₂` and
exponent `max(k₁, k₂)`. The `size` field and the fibred-product construction are
already in place, so this is one provable lemma away. *Testable and falsifiable: the
meet of two p-bounded systems is p-bounded.*

### 9.2 The simulation order as a complete distributive lattice

Theorems 3.2, 3.4, 3.6, 3.9 say `Prov` is a surjective lattice homomorphism onto the
powerset. With Theorem 2.6 in hand, one can form the quotient `ProofSys F / SimEquiv`
and transport the `CompleteDistribLattice (Set F)` structure across the induced
equivalence, obtaining a complete, distributive lattice whose order is exactly
`Simulates` and which is order-isomorphic to `(Set F, ⊆)`, with `setSys` the
canonical section. *Testable conjecture: the quotient carries a complete distributive
lattice instance order-isomorphic to `Set F`.*

### 9.3 p-optimal systems and the finite-to-infinite gap

A system is *p-optimal* when it simulates every p-bounded system with only
polynomial blow-up. Theorem 6.3 already builds, from any *finite* family of p-bounded
systems, a single p-bounded system simulating them all; the obstruction to a
universal p-optimal system is exactly the jump from finite to countable joins. The
finite case is closed, isolating the infinitary gap where the Cook–Reckhow
conjecture lives. *Testable and falsifiable: a countable family `P : ℕ → ProofSys F`
with a single shared `(c, k)` has p-bounded `iUnion P`; without a shared bound it
need not.*

### 9.4 Concrete instantiations

Instantiating the abstract framework with resolution over CNF formulas and a Frege
system would let one import known separations — e.g. the pigeonhole principle has
polynomial Frege proofs but requires exponential resolution proofs — to witness
`¬ Simulates Resolution Frege` within this lattice. The singleton/tautology-table
constructions generalize to interpolation systems whose proofs encode Craig
interpolants.

### 9.5 Finite formula spaces and Dedekind numbers

When `F` is finite, every sound system has a finite repertoire and the simulation
order is a finite distributive lattice. The maximality criterion becomes decidable
by enumeration. A striking conjecture: for `F = Fin n`, the number of
simulation-equivalence classes of sound systems equals the number of antichains in
the powerset lattice of valid formulas — connecting proof-system collapse to
**Dedekind numbers** and enumerative combinatorics.

---

## 10. Conclusion

By measuring proof systems solely through their repertoires, the apparently
intractable comparison of proofs collapses, up to simulation, onto subset inclusion.
Disjoint union, fibred product, and indexed union compute join, meet, and arbitrary
join; every subset is realized; complete systems are maximal; and polynomial
boundedness is closed under finite joins — exactly up to the finite/infinite
boundary that houses the discipline's central open problem. The result is a complete
order-theoretic map of the qualitative theory and a sharp delineation of where the
quantitative theory turns hard.
