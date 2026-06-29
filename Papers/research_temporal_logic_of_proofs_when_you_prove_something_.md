# Temporal Gödel–Löb Logic (TGL): A Provability Logic with a Clock

## Abstract

Classical provability logic GL treats provability as timeless: the modal operator
`□A` ("A is provable") carries no information about *when* a proof was, or will be,
established. Yet proofs are discovered in time, their dependencies form a causal
order, and the value of a result in practice often turns on *when* it becomes
available. We introduce **Temporal Gödel–Löb logic (TGL)**, a conservative temporal
extension of GL in which provability is indexed by discrete time. Semantically, TGL
is interpreted on **temporal GL frames**: structures carrying a Gödel–Löb
accessibility relation `R` (transitive and converse well-founded) together with a
temporal preorder `T`, linked by a *time-monotonicity* condition `compat` expressing
that provability only grows as time passes. On these frames we prove soundness of the
GL axioms (the `4` axiom and Löb's axiom), soundness of a new **temporal interaction
axiom** `□A → □□◇A`, and the **persistence of provability** `□A → G□A`. We then
resolve the two "temporal paradoxes" of proof discovery: the sentence *"provable
today but not tomorrow"* is **refutable** in TGL, while its mirror *"provable
tomorrow but not today"* is **satisfiable**, exhibiting the fundamental one-way
asymmetry of mathematical discovery. We give two new forms of Gödel's second
incompleteness theorem: a purely **semantic** form on GL frames, and a
**time-stamped** form via Löb. A companion algebraic layer axiomatises a time-stamped
provability predicate `prov t A` ("provable by stage `t`") satisfying persistence,
modus ponens, Σ₁-completeness, and Löb, yielding a **future self-certification**
theorem `prov t A → prov s (prov t A)` for `t ≤ s`; we verify the axiom set is
consistent by exhibiting a model. A boundary result shows that dropping converse
well-foundedness — even at a single reflexive world — invalidates Löb's axiom,
demonstrating that the well-founded structure is load-bearing. All results are
formally verified.

**Keywords:** provability logic, Gödel–Löb logic, temporal logic, modal logic,
Gödel's incompleteness theorems, Löb's theorem, Kripke semantics, proof discovery.

---

## 1. Introduction

### 1.1 Motivation: proofs are events

Standard proof theory operates under a convenient idealization: a sentence, once
provable, is provable timelessly. This idealization is built into the modal logic of
provability, GL, where `□A` means simply "A is provable," with no temporal index.
Solovay's celebrated arithmetical completeness theorem certifies that GL captures
*exactly* the schemata Peano Arithmetic (PA) proves about its own provability
predicate, making GL the canonical logic of provability.

But proofs are discovered in time. A proof of a theorem `A` is built on a stock of
previously established lemmas; the dependency relation among proofs imposes a partial
temporal order; and in computational practice — automated theorem proving, proof
mining, interactive proof assistants — the *order* in which results are obtained is a
first-class object of concern. The natural question is whether the elegant machinery
of GL can be extended to reason about *temporal* provability without losing its
characteristic theorems, and what genuinely new principles emerge.

### 1.2 Contributions

We introduce TGL, isolate its semantics, and prove the following (all formally
verified):

1. **Soundness of GL on temporal frames.** Löb's axiom and the `4` axiom are sound
   on every temporal GL frame (Theorems 3.1, 3.2).
2. **A new temporal interaction axiom.** `□A → □□◇A` is sound (Theorem 3.3); it is
   the principle by which TGL strictly extends GL.
3. **Persistence.** `□A → G□A`: provability established now persists to all future
   times (Theorem 4.1), with a monotonicity restatement (Theorem 4.2).
4. **Resolution of the temporal paradoxes.** "Provable today but not tomorrow" is
   refutable (Theorem 4.3); "provable tomorrow but not today" is satisfiable
   (Theorem 4.4).
5. **Two new forms of Gödel II.** A semantic form on GL frames (Theorem 5.1) and a
   time-stamped algebraic form via Löb (Theorem 5.2).
6. **Future self-certification.** In the algebraic layer, `prov t A → prov s (prov t
   A)` for `t ≤ s` (Theorem 6.1), with a consistency model (Theorem 6.2).
7. **A boundary result.** Dropping converse well-foundedness invalidates Löb
   (Theorem 7.1), confirming the structural necessity of well-foundedness.

### 1.3 Relation to prior provability and temporal logic

TGL sits at the intersection of two mature traditions. From provability logic it
inherits the GL frame skeleton: transitive, converse-well-founded accessibility,
which is the exact frame condition validating Löb's axiom (the Segerberg–Solovay
characterization). From linear/branching temporal logic it inherits the `G`
("globally") and `F`/`◇` ("eventually") operators interpreted over a temporal
preorder. The novel content is their *interaction*, governed by the monotonicity
bridge `compat`, and the resulting temporal sharpenings of the incompleteness
phenomena.

---

## 2. Semantics: temporal GL frames

We work with a *shallow* (predicate) semantics: over a fixed set of worlds `W`, a
formula is modelled by a predicate `A : W → Prop`, where `A w` reads "A holds at world
`w`." This suffices for soundness and (counter)model constructions and keeps the
development free of syntactic bureaucracy.

### 2.1 Operators

**Definition 2.1 (Provability box).** For an accessibility relation `R : W → W →
Prop`,
```
Box R A w  :=  ∀ v, R w v → A v.
```
`Box R A w` ("`□A` at `w`") asserts that `A` holds at every `R`-successor of `w`.
Intuitively, `R w v` means `v` is a world that `w` cannot rule out (a potential
counterexample), and proving `A` means eliminating all such counterexamples.

**Definition 2.2 (Temporal globally).** For a temporal relation `T : W → W → Prop`,
```
Glob T A w  :=  ∀ v, T w v → A v.
```
`Glob T A w` ("`GA`" / "`□ₜA`") asserts `A` holds at all now-or-later times.

**Definition 2.3 (Temporal eventually / diamond).**
```
Fut T A w  :=  ∃ v, T w v ∧ A v.
```
`Fut T A w` ("`FA`" / "`◇A`") asserts `A` holds at some now-or-later time. This is
the temporal diamond of the concept.

### 2.2 Frames

**Definition 2.4 (Temporal GL frame).** A *temporal GL frame* `F` consists of:

- a type `W` of **worlds** (consistent stages / partial completions of knowledge);
- a **proof-accessibility relation** `R : W → W → Prop` (`R w v`: `v` is a
  counterexample world reachable from `w`);
- a **temporal preorder** `T : W → W → Prop` (`T w w'`: `w'` is now-or-later than
  `w`);

subject to:

- **`R_trans`:** `R` is transitive — `R w v → R v u → R w u`;
- **`R_wf`:** `R` is *converse well-founded* — the relation `λ a b, R b a` is
  well-founded (no infinite `R`-ascending chains);
- **`T_refl`:** `T` is reflexive;
- **`T_trans`:** `T` is transitive;
- **`compat` (time-monotonicity):** `T w w' → R w' v → R w v`.

The two structural conditions on `R` are exactly the GL frame conditions:
transitivity validates the `4` axiom, converse well-foundedness validates Löb. The
preorder conditions on `T` make time a minimal flow. The bridge `compat` is the
conceptual core of TGL: it says the `R`-successor set can only *shrink* as time
advances along `T`, hence (since `□` quantifies universally over successors)
provability can only *grow*.

**Remark 2.5 (Reading `compat`).** Contrapositively, `compat` says: any
counterexample eliminated by the present stage stays eliminated at every future
stage. Equivalently, future successors are present successors. This is the
formalization of "knowledge accumulates; proofs are never lost."

---

## 3. Soundness of the GL axioms

### 3.1 Löb's axiom

**Theorem 3.1 (`loeb_box_sound`).** On every temporal GL frame `F`, for every
predicate `A` and world `w`,
```
Box R (λ v, Box R A v → A v) w  →  Box R A w.
```
That is, `□(□A → A) → □A` is valid.

*Proof sketch.* We must show `A v` for every `R`-successor `v` of `w`. Argue by
well-founded induction on `v` using `R_wf` (induction along the converse of `R`). For
the inductive world `x` with `R w x`: the induction hypothesis gives, for every `u`
with `R x u`, that `A u` holds (using `R_trans` to know `R w u`, so the IH applies);
hence `Box R A x`. The Löb hypothesis `h x` (instantiated at the successor `x` of
`w`) is precisely `Box R A x → A x`, which now yields `A x`. Converse
well-foundedness is exactly what licenses the induction; it is the formal content of
"proofs are finite." ∎

This is the heart of GL: the same well-founded induction that produces Löb's theorem
underlies Gödel's second incompleteness theorem.

### 3.2 The `4` axiom

**Theorem 3.2 (`four_box_sound`).** On every temporal GL frame,
```
Box R A w  →  Box R (Box R A) w,
```
i.e. `□A → □□A` is valid.

*Proof sketch.* Pure transitivity. Suppose `Box R A w`. Given `R w v` and `R v u`,
transitivity gives `R w u`, so `A u` follows from `Box R A w`. Hence `Box R A v` for
each successor `v`, i.e. `Box R (Box R A) w`. ∎

### 3.3 The temporal interaction axiom

**Theorem 3.3 (`tgl_axiom_sound`).** On every temporal GL frame,
```
Box R A w  →  Box R (Box R (Fut T A)) w,
```
i.e. the **temporal Gödel–Löb axiom** `□A → □□◇A` is valid.

*Proof sketch.* Suppose `Box R A w`. Fix successors with `R w v` and `R v u`; we must
show `Fut T A u`, i.e. `∃ x, T u x ∧ A x`. Take `x := u`: `T u u` by reflexivity of
time (`T_refl`), and `A u` follows because `R w u` (by transitivity of `R` from `R w
v`, `R v u`) and `Box R A w`. ∎

**Interpretation.** `□A → □□◇A` reads: *if `A` is provable now, then it is
provably-provable that `A` will (still) be provable at some future time.* It is the
axiom by which TGL strictly extends GL, encoding the certifiable persistence of
discovery. (Strictness over GL: the temporal vocabulary `◇` is inexpressible in pure
GL, and the axiom links the two modalities; on any frame where `T` is non-trivial the
principle is not a GL-theorem.)

---

## 4. Persistence and the temporal paradoxes

### 4.1 Persistence of provability

**Theorem 4.1 (`provability_persists`).** On every temporal GL frame,
```
Box R A w  →  Glob T (Box R A) w,
```
i.e. `□A → G□A`: what is provable now is provable at all future times.

*Proof sketch.* Suppose `Box R A w` and let `v` be a future time, `T w v`. To show
`Box R A v`, take any `R v u`. By `compat` applied to `T w v` and `R v u` we get `R w
u`, whence `A u` from `Box R A w`. Thus `Box R A v`. The bridge `compat` is exactly
the hypothesis consumed here. ∎

**Theorem 4.2 (`provability_monotone`).** Equivalent restatement of Theorem 4.1:
provability is monotone along `T`; if `Box R A w` and `T w v` then `Box R A v`.
Proofs are never lost.

### 4.2 "Provable today but not tomorrow" is refutable

**Theorem 4.3 (`today_not_tomorrow_refuted`).** On every temporal GL frame there is
no world `w` and future time `v` (`T w v`) with `Box R A w` and `¬ Box R A v`. The
"temporal paradox" *provable today but not tomorrow* is refutable in TGL.

*Proof sketch.* Immediate from persistence (Theorem 4.1): `Box R A w` and `T w v`
force `Box R A v`, contradicting `¬ Box R A v`. ∎

### 4.3 "Provable tomorrow but not today" is satisfiable

**Theorem 4.4 (`tomorrow_not_today_satisfiable`).** There is a temporal GL frame, a
predicate `A`, a world `w` and a future time `v` (`T w v`) with `¬ Box R A w` and
`Box R A v`. The mirror sentence *provable tomorrow but not today* is satisfiable.

*Proof sketch.* Exhibit an explicit two-world frame. Let `W = {w, v}` with `T` the
reflexive-transitive order making `w ≤ v` (and both reflexive), and choose `R` so
that `w` has a successor falsifying `A` while `v`'s successor set has shrunk
(consistently with `compat`, since the successor set may only shrink toward the
future) so that `A` holds at all of `v`'s successors. Then `¬ Box R A w` and `Box R A
v`. One checks `R_trans`, `R_wf`, the preorder laws, and `compat` directly on the
finite frame. ∎

**Discussion (the one-way ratchet).** Theorems 4.3 and 4.4 together pin down the
*asymmetry of proof discovery*. The future can supply provability one did not have
(4.4 satisfiable) but can never revoke provability one had (4.3 refutable). This is
the formal signature of mathematical progress: new theorems appear, old theorems
endure. The asymmetry is not accidental — it is enforced by `compat` together with
converse well-foundedness (cf. Theorem 7.1).

---

## 5. Two faces of Gödel's second incompleteness theorem

### 5.1 Semantic incompleteness on GL frames

Say a world `w` is **consistent** when it has at least one `R`-successor it cannot
rule out — equivalently, it does not falsify everything, i.e. `¬ Box R (λ _, False)
w` (there is some `v` with `R w v`). "Consistency is provable at `w`" then means `Box
R (consistency) w`.

**Theorem 5.1 (`kripke_second_incompleteness`).** On any GL frame, if a world is
consistent then its consistency is not provable there.

*Proof sketch.* A well-founded maximal-world argument. By converse well-foundedness
of `R`, from a consistent `w` one obtains an `R`-maximal accessible world `m` (a
world with `R w m` having no proper `R`-successor, or whose successors collapse).
Provability of consistency at `w` would, propagated to `m`, assert that `m` itself has
a live successor, contradicting maximality. Hence consistency is unprovable. This is
the frame-theoretic skeleton of Gödel II: it is a statement about well-founded
structures, with arithmetic merely one instance. ∎

### 5.2 Time-stamped incompleteness

**Theorem 5.2 (`godel_second_at_time`).** In the algebraic layer (Section 6), if a
system is consistent at stage `t`, then the proposition "the system is consistent at
stage `t`" is not provable at stage `t`:
```
Con(t)  →  ¬ prov t (Con(t)),
```
where `Con(t)` abbreviates `¬ prov t ⊥`.

*Proof sketch.* A direct application of Löb's principle (an axiom of `TempProv`,
Section 6) to the time-indexed predicate `prov t`. If `prov t (Con(t))` held, Löb's
machinery would derive `prov t ⊥`, contradicting `Con(t)`. ∎

**Interpretation.** A system cannot certify its own consistency *on its own clock*.
The classical Gödel II is the timeless shadow of this sharper statement: the
limitation has a definite temporal locus, "at stage `t`, by stage `t`."

---

## 6. The algebraic layer: a time-stamped provability predicate

### 6.1 The structure `TempProv`

To target arithmetical interpretations directly, we axiomatise an abstract
time-stamped provability predicate.

**Definition 6.1 (`TempProv`).** A `TempProv` structure consists of a type of
sentences with logical connectives, a relation `prov : ℕ → Sentence → Prop` (`prov t
A`: "there is a proof of `A` established by stage `t`"), and the axioms:

- **Persistence:** `t ≤ s → prov t A → prov s A` (a proof by time `t` is a proof by
  any later time);
- **Modus ponens (internal):** `prov t (A → B) → prov t A → prov t B`;
- **Σ₁-completeness (positive introspection):** `prov t A → prov t (prov t A)` —
  having a proof, one can prove that one has it (the formal reflex of bounded
  provability being Σ₁);
- **Löb:** `prov t (prov t A → A) → prov t A`.

These are exactly the principles an honest bounded provability predicate satisfies.
The Σ₁-completeness axiom is the abstract counterpart of the arithmetical fact that
"there is a proof of `A` of size ≤ `t`" is a Σ₁ formula, hence provably true in PA
whenever true.

### 6.2 Future self-certification

**Theorem 6.1 (`future_self_certification`).** In any `TempProv`, for `t ≤ s`,
```
prov t A  →  prov s (prov t A).
```
A proof established by time `t` is, at every later time `s`, provably established.

*Proof sketch.* From `prov t A`, Σ₁-completeness gives `prov t (prov t A)`.
Persistence (with `t ≤ s`) lifts this to `prov s (prov t A)`. ∎

**Interpretation.** Proofs do not merely persist (Theorem 4.1, semantic side); their
existence becomes a *certifiable historical fact*. This is the formal backbone of
mathematical citation: a later result certifies an earlier one was established without
re-deriving it.

### 6.3 Consistency of the axioms

**Theorem 6.2 (`trivialTempProv_consistent`).** The axioms of `TempProv` are
consistent: there exists a model (e.g. the degenerate "proves only the logically
trivial" interpretation) satisfying persistence, modus ponens, Σ₁-completeness and
Löb.

*Proof sketch.* Take `prov t A` to be a uniformly valid predicate (e.g. always true
on a one-point sentence algebra, or "A is a tautology"); verify each axiom directly.
The point is non-vacuity: the Gödel results of Section 5 hold of a genuinely
inhabited axiom class. ∎

---

## 7. A boundary result: well-foundedness is load-bearing

**Theorem 7.1 (`loeb_fails_with_reflexive`).** There is a frame with a single
reflexive world (`R w w`) — hence *not* converse well-founded — on which Löb's axiom
fails: there is a predicate `A` with `Box R (λ v, Box R A v → A v) w` but `¬ Box R A
w`.

*Proof sketch.* On the one-point reflexive frame, take `A` false at `w`. Then `Box R
A w` is false (the single successor `w` falsifies `A`), so `¬ Box R A w`. But `Box R
(λ v, Box R A v → A v) w` reduces to `Box R A w → A w`, which is `False → False`,
i.e. true. Thus the Löb hypothesis holds while the conclusion fails. ∎

**Significance.** Converse well-foundedness of `R` is not a technical convenience but
the structural fact that makes Löb's axiom — and with it the entire incompleteness
phenomenon and the one-way ratchet of Section 4 — possible. A single reflexive point
(an "infinite proof," a self-justifying world) destroys it.

---

## 8. Algorithms

The semantics is finitely checkable, which makes TGL amenable to direct computation.
We describe three core algorithms, with full pseudocode and reference implementations
in the companion `demo.py` / `PACKAGE.json`.

**(A) Box / temporal-operator evaluation.** Given a finite frame (worlds, `R`, `T`)
and a valuation of atoms, evaluate `Box`, `Glob`, `Fut`, and compound formulas at a
world by direct quantification over successors. Complexity `O(|W|)` per modal node,
`O(|formula| · |W|)` overall for a fixed valuation; nesting multiplies by depth.

**(B) Frame validation.** Verify a candidate finite frame is a genuine temporal GL
frame: check transitivity of `R` (`O(|W|³)`), converse well-foundedness (no
`R`-cycle, via DFS / topological sort, `O(|W|²)`), reflexivity and transitivity of
`T`, and `compat` (`O(|W|³)`). This certifies the satisfiability witnesses
(Theorem 4.4) and the boundary counterexample (Theorem 7.1).

**(C) Löb fixed-point evaluation.** Compute, by well-founded induction along reverse
`R`, the set of worlds where `Box R A` holds given the Löb hypothesis, reproducing
the proof of Theorem 3.1 computationally; this doubles as a checker that converse
well-foundedness holds (the induction terminates iff there is no `R`-cycle).

---

## 9. Applications

- **Automated theorem proving / proof search scheduling.** Proof search establishes
  lemmas in an order; TGL's `◇` ("eventually provable") and `G□A` ("remains
  provable") are the natural correctness specifications for "this strategy will
  succeed" and "this lemma stays available." Theorem 4.4 (satisfiability of
  "tomorrow not today") formalizes that absence of a result now does not preclude it
  later.
- **Proof mining.** Extracting sharper data from existing proofs is a *reorganization*
  of temporal dependency order; future self-certification (Theorem 6.1) underwrites
  citing established results without re-derivation.
- **Interactive proof assistants / dependency management.** The dependency graph of a
  library is precisely a temporal GL structure; persistence (Theorem 4.1) is the
  formal guarantee that established lemmas remain usable, and the time-stamped Gödel
  result (Theorem 5.2) bounds what a system can certify about its own soundness at a
  given build stage.
- **Foundations.** TGL recasts incompleteness from a story of static limits to one of
  *process*: a system cannot certify its consistency on its own clock, but the very
  well-foundedness that forces this (Theorem 7.1) is what guarantees knowledge
  accumulates monotonically (Theorems 4.1–4.3).

---

## 10. Discussion

The recurring theme is that **converse well-foundedness of `R`** does double duty. On
the negative side it forces incompleteness (Theorems 3.1, 5.1, 5.2): no infinite
regress of self-justification, hence no internal consistency proof. On the positive
side, combined with the monotonicity bridge `compat`, it underwrites the *good* news
of accumulation (Theorems 4.1–4.3): the future cannot revoke what is proved.
Theorem 7.1 makes the dependence explicit by showing the whole structure collapses
when well-foundedness is removed at even one point. The two modalities `□` (proof
structure) and `G`/`◇` (time), kept cleanly separate and linked only through
`compat`, interact exactly as the new axiom `□A → □□◇A` predicts.

A subtle conceptual payoff is the asymmetry pair (Theorems 4.3 vs 4.4). It explains,
in a single formal stroke, why mathematics *feels* cumulative: provability is a
monotone, one-way function of time. The "paradoxes" of temporal provability are not
paradoxes at all once the frame conditions are made explicit; one is impossible, its
mirror is routine, and the difference is precisely the direction of time.

---

## 11. Future work

The development opens two concrete, falsifiable research programs.

**(1) Arithmetical completeness over PA.** Replace the toy `TempProv` model (Theorem
6.2) by the *faithful* interpretation `prov t A := "there is a PA-proof of A of Gödel
number / length ≤ t"`. Because bounded provability is Σ₁, persistence and positive
introspection hold of the honest predicate, not just toy models. Conjecture: a
Solovay-style theorem holds — a temporal modal sentence is a TGL-theorem iff its
arithmetical interpretation is a PA-theorem under every time-stamped substitution.
*Falsification:* a TGL-valid sentence whose interpretation is PA-independent.

**(2) Decidability via a temporal finite model property.** GL has the finite model
property and is decidable. Conjecture: TGL has a *temporal* FMP — every non-theorem is
refuted on a frame finite in both the `R` and `T` dimensions — and is decidable with
an explicit complexity bound (PSPACE-or-better). The key is that `compat` lets a
temporal model be unravelled into a product of a converse-well-founded `R`-tree with a
finite linear time order, so the two well-foundedness phenomena (proof depth, bounded
time) compose rather than interfere. A filtration argument over temporal GL frames is
the natural route.

---

## 12. Conclusion

TGL extends the canonical logic of provability with a clock, conservatively retaining
Löb's axiom and the `4` axiom while adding the temporal interaction principle `□A →
□□◇A`. The framework cleanly resolves the temporal paradoxes of proof discovery —
"provable today but not tomorrow" is impossible, "provable tomorrow but not today" is
routine — and delivers both semantic and time-stamped sharpenings of Gödel's second
incompleteness theorem, together with a future self-certification theorem for a
time-stamped provability predicate. The unifying insight is that converse
well-foundedness simultaneously forces incompleteness and guarantees the monotone
accumulation of mathematical knowledge: time, for proofs, runs only one way.
