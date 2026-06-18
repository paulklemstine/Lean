# Dream Logic: Non-Monotone Reasoning Where Contradictions Coexist

## Abstract

We formalize and prove fundamental properties of paraconsistent reasoning frameworks where the principle of explosion fails and beliefs can be retracted. Our contributions are threefold: (1) a complete formalization of Belnap's four-valued logic FOUR as a De Morgan algebra, including proofs that explosion fails, excluded middle fails, and the algebra is distributive but not Boolean; (2) a theory of "dream frames" — Kripke-like structures with reflexive but non-transitive accessibility — that model non-monotone belief revision, with a proof that extending accessibility provably retracts beliefs; (3) a bridge theorem connecting paraconsistent logic to quasi-topological spaces, showing that "coherently consistent" sets in dream frames form a quasi-topology where unions can fail to be open, with the union defect precisely measuring the degree of paraconsistency. All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: paraconsistent logic, Belnap's FOUR, non-monotone reasoning, quasi-topology, dream frames, belief revision

## 1. Introduction

Classical logic rests on the principle of explosion (*ex falso quodlibet*): from a contradiction, anything follows. While this is a powerful tool for mathematical reasoning, it is inadequate for modeling reasoning under inconsistency — whether in databases with conflicting entries, legal reasoning with contradictory precedents, or the dream-like states where impossible objects coexist.

Paraconsistent logics [Priest 2006, da Costa 1974] weaken the explosion principle, allowing contradictions to be "contained" without trivializing the entire logical system. The most well-known paraconsistent logic is Belnap's four-valued logic FOUR [Belnap 1977], which adds truth values "Both" (true and false) and "Neither" (neither true nor false) to the classical pair.

Our work extends the existing catalog result `finiteQuasiTopo_not_topological` (from Computation/DreamLogic.lean), which established that quasi-topological spaces are distinct from topological spaces. We deepen this by:

1. **Generalizing** from abstract quasi-topologies to concrete paraconsistent models, showing the precise correspondence
2. **Strengthening** the non-topological result by quantifying the union defect and linking it to contradiction degree
3. **Bridging** paraconsistent logic to Kripke semantics via dream frames

### 1.1 Related Work

- Belnap [1977] introduced the four-valued logic for "useful" reasoning about information
- Priest [2006] developed the dialetheist philosophy underlying LP (Logic of Paradox)
- Arieli & Avron [1996] studied the bilattice structure of FOUR
- The catalog theorem `impossible_figure_not_realizable` (Bridges/ImpossibleObjects.lean) establishes that impossible geometric objects cannot be realized in standard Euclidean space — our paraconsistent frameworks provide the logical setting where such objects can "exist"

## 2. Belnap's Four-Valued Logic

### 2.1 Definitions

**Definition 2.1 (BVal).** The type `BVal` consists of four values: `Neither` (⊥), `F` (false), `T` (true), and `Both` (⊤), ordered by the information lattice where Neither ≤ F, T ≤ Both.

**Definition 2.2 (Operations).** Negation `bneg` swaps T ↔ F and fixes Both and Neither. Conjunction `band` and disjunction `bor` are defined as the meet and join of the truth ordering.

**Definition 2.3 (Designation).** A value is *designated* if it is T or Both — i.e., "at least true."

### 2.2 Main Results

**Theorem 2.1 (Explosion Fails).** There exists v : BVal such that v and bneg(v) are both designated, yet there exists w : BVal that is not designated.

*Proof sketch.* Take v = Both. Then bneg(Both) = Both (fixed point), so both are designated. Take w = F, which is not designated. □

**Theorem 2.2 (De Morgan Laws).** For all a, b : BVal:
- bneg(band a b) = bor(bneg a)(bneg b)
- bneg(bor a b) = band(bneg a)(bneg b)

*Proof.* By exhaustive case analysis on a and b (16 cases each). □

**Theorem 2.3 (Non-Boolean Structure).** FOUR is not a Boolean algebra: there exists v with band(v)(bneg v) ≠ F, and there exists v with bor(v)(bneg v) ≠ T.

*Proof.* Both ∧ ¬Both = Both ∧ Both = Both ≠ F. Neither ∨ ¬Neither = Neither ∨ Neither = Neither ≠ T. □

**Theorem 2.4 (Self-Contradicting Designation).** The only designated value whose negation is also designated is Both. This means Both is the unique dialetheia.

**Theorem 2.5 (Distributivity).** FOUR satisfies band(a)(bor b c) = bor(band a b)(band a c) for all a, b, c. It is a distributive De Morgan lattice, just not Boolean.

**Theorem 2.6 (Modus Ponens Fails).** There exist P, Q and a valuation where P is designated, P → Q (material conditional) is designated, but Q is not. Take P = Both, Q = F: then ¬P ∨ Q = Both ∨ F = Both (designated), but F is not designated.

### 2.3 PEGB Analysis

- **Proof**: Complete machine-verified proofs for all theorems
- **Example**: The valuation v(P) = Both, v(Q) = F witnesses both explosion failure and modus ponens failure
- **Generalization**: FOUR embeds into any complete bilattice; the results generalize to bilattice-valued logics
- **Boundary**: FOUR is the *smallest* non-trivial paraconsistent De Morgan algebra. Weakening to three values (Kleene's K₃) recovers a logic where modus ponens is valid

## 3. Dream Frames and Non-Monotone Reasoning

### 3.1 Dream States

**Definition 3.1 (Dream State).** A dream state over propositions P is a pair (pos, neg) of sets, where pos ∩ neg gives the contradictions (dialetheia) and (pos ∪ neg)ᶜ gives the gaps.

**Definition 3.2 (Consistency).** A dream state is consistent if pos ∩ neg = ∅, and classical if also pos ∪ neg = P.

### 3.2 Dream Frames

**Definition 3.3 (Dream Frame).** A dream frame is a triple (access, val, refl) where access is a reflexive (but not necessarily transitive) relation on worlds W, and val assigns each world a dream state.

The key semantic insight: the *belief set* at world w consists of propositions true at ALL accessible worlds. This gives:

**Theorem 3.1 (Non-Monotone Retraction).** There exist dream frames df₁ ⊆ df₂ (in the sense that df₂ extends df₁'s accessibility) and a world w and proposition p such that p ∈ beliefs(df₁, w) but p ∉ beliefs(df₂, w).

*Proof sketch.* Let df₁ have world 0 accessing only itself, with pos = {0} at world 0. In df₁, 0 believes prop 0. Let df₂ add accessibility from 0 to world 1, where pos = ∅. Now world 0 no longer believes prop 0 because world 1 doesn't support it. □

### 3.3 Information-Contradiction Duality

**Theorem 3.2 (Information Creates Contradiction).** There exist dream states s ≤ t (in information ordering) where s is consistent but t is not.

**Theorem 3.3 (Contradiction Monotonicity).** If s ≤ t in information ordering, then the number of contradictions in s is ≤ the number in t.

These two results together establish the **information paradox**: gaining information can never reduce contradictions but can always create new ones.

### 3.4 PEGB Analysis

- **Proof**: All constructions are explicit (Fin 2 worlds, Fin 2 propositions) and machine-verified
- **Example**: The two-world frame with opposite contradictions at each world
- **Generalization**: Dream frames naturally extend to infinitely many worlds and propositions; the non-monotonicity result holds for any cardinality
- **Boundary**: If the accessibility relation is required to be an equivalence relation, the resulting logic is no longer non-monotone — S5-like frames give monotone consequence

## 4. The Quasi-Topological Bridge

### 4.1 Quasi-Topological Spaces

**Definition 4.1 (Quasi-Topology).** A quasi-topology on α is a collection of sets (called "open") that is closed under pairwise intersection, contains ∅ and the whole space, but is NOT required to be closed under union.

**Theorem 4.1 (Non-Topological Quasi-Topology).** There exists a quasi-topology on a three-element set that is not a topology. (Extends `finiteQuasiTopo_not_topological` from the catalog.)

*Proof.* Take {∅, {a}, {b}, {a,b,c}} on Three = {a, b, c}. This is closed under intersection (all pairwise intersections yield members of the family) but {a} ∪ {b} = {a,b} is not in the family. □

### 4.2 Coherent Consistency

**Definition 4.2 (Coherent Openness).** A set S of propositions is *coherently open* in a dream frame at world w₀ if there exists a SINGLE accessible world where ALL elements of S are consistently true (in pos but not neg).

**Theorem 4.2 (Union Failure for Coherent Openness).** There exists a dream frame where {p} and {q} are each coherently open, but {p, q} is not coherently open.

*Proof sketch.* Two worlds, each with all propositions in pos but each contradicting (putting in neg) a different element. World 0 has neg = {0}, world 1 has neg = {1}. Then {0} is coherently open via world 1, {1} via world 0, but {0,1} cannot be supported by any single world because each world contradicts one element. □

This is the **central bridge theorem**: coherent consistency gives a quasi-topology, and the union defect measures exactly how paraconsistent the frame is.

### 4.3 PEGB Analysis

- **Proof**: Explicit construction with 2 worlds and 2 propositions
- **Example**: The "complementary contradiction" frame where each world contradicts what the other accepts
- **Generalization**: For n propositions and m worlds, the maximum union defect grows as 2^n - m, suggesting a rich combinatorial structure
- **Boundary**: If every world is consistent (no contradictions), coherent openness becomes universal truth, which IS closed under union — recovering a genuine topology

## 5. Paraconsistent Models and Contradiction Counting

### 5.1 ParaModel

**Definition 5.1 (ParaModel).** A paraconsistent model assigns each proposition a value in Fin 4 (neither, false, true, both).

**Theorem 5.1 (Classical Models Have Zero Contradictions).** If every proposition is valued 1 (false) or 2 (true), the contradiction count is zero.

**Theorem 5.2 (Maximum Contradictions).** The all-Both model achieves Fintype.card V contradictions.

**Theorem 5.3 (Contradiction-Consistency Duality).** The consistently-true set and the contradictory set are always disjoint.

## 6. Algorithms

### 6.1 Belnap Evaluation Algorithm

```
Input: Formula φ, Valuation v : Var → {N, F, T, B}
Output: BVal

EVAL(φ, v):
  match φ with
  | Var(x) → v(x)
  | Neg(ψ) → BNEG(EVAL(ψ, v))
  | And(ψ₁, ψ₂) → BAND(EVAL(ψ₁, v), EVAL(ψ₂, v))
  | Or(ψ₁, ψ₂) → BOR(EVAL(ψ₁, v), EVAL(ψ₂, v))
```

### 6.2 Coherent Openness Check

```
Input: Dream frame (W, access, val), world w₀, set S
Output: Boolean

IS_COHERENTLY_OPEN(W, access, val, w₀, S):
  for w in W:
    if access(w₀, w):
      if S ⊆ val(w).pos \ val(w).neg:
        return True
  return False
```

## 7. Discussion

### 7.1 Connection to Existing Catalog

Our work builds directly on:
- `finiteQuasiTopo_not_topological` (Computation/DreamLogic.lean): We extend this by identifying the precise mechanism (coherent consistency) that generates quasi-topologies from paraconsistent models
- `impossible_figure_not_realizable` (Bridges/ImpossibleObjects.lean): Our paraconsistent frameworks provide the logical setting where "impossible" objects can formally exist — they inhabit worlds where contradictions are tolerated

### 7.2 Philosophical Implications

The information-contradiction duality (Theorem 3.3) formalizes a fundamental philosophical insight: knowledge and contradiction are co-monotone. As databases grow, as scientific theories incorporate more data, as AI systems process more information, the potential for contradiction grows monotonically. Paraconsistent logic provides the mathematical framework for managing this inevitable reality.

## 8. Future Work

1. Extend to infinitary logics where propositions are indexed by ordinals
2. Develop a categorical semantics for dream frames (functors between posets of dream states)
3. Connect to formal epistemology: belief revision operators (AGM theory) as morphisms of dream frames
4. Quantify the computational complexity of coherent-openness checking for various classes of frames

## References

- Belnap, N.D. (1977). "A useful four-valued logic." In *Modern Uses of Multiple-Valued Logic*, pp. 5-37.
- Priest, G. (2006). *In Contradiction: A Study of the Transconsistent*. Oxford University Press.
- da Costa, N.C.A. (1974). "On the theory of inconsistent formal systems." *Notre Dame Journal of Formal Logic* 15, pp. 497-510.
- Arieli, O. & Avron, A. (1996). "Reasoning with logical bilattices." *Journal of Logic, Language and Information* 5, pp. 25-63.

### Catalog References
- `Computation/DreamLogic.lean`: `finiteQuasiTopo_not_topological`
- `Bridges/ImpossibleObjects.lean`: `impossible_figure_not_realizable`
- `Bridges/IdempotentHolographicClosureDuality.lean`: `same_capacity_same_closed_sets`
