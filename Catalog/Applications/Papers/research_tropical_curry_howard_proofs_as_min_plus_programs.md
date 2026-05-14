# Tropical Curry–Howard: Proofs as Min-Plus Programs

## Abstract

We introduce a **tropical proof calculus** — a syntactic rewrite system on proof terms whose semantics is the min-plus (tropical) semiring — and prove its fundamental metatheoretic properties. Propositions carry costs (natural numbers), proofs are syntax trees with sequential composition (`cut`), parallel composition (`plus`), and nondeterministic choice (`min`), and cut elimination corresponds to distributing sequential composition over choice. We establish:

1. **Soundness**: Every reduction step preserves tropical evaluation (cost).
2. **Strong normalization**: The rewrite system terminates, via a polynomial interpretation mapping cut to multiplication and min to addition.
3. **Normal form existence**: Every term reduces to a normal form.
4. **Semantic optimality**: All normal forms of a given term have the same tropical cost.

All results have been machine-verified in Lean 4 with Mathlib, using no axioms beyond `propext`, `Classical.choice`, and `Quot.sound`. The formalization provides a certified nucleus for **tropical proof theory**, connecting the Curry–Howard correspondence to shortest-path algorithms, dynamic programming, and tropical geometry.

**Keywords:** tropical logic, Curry–Howard correspondence, min-plus semantics, cut elimination, strong normalization, idempotent semiring, proof optimization, certified rewriting.

---

## 1. Introduction

### 1.1 Motivation

The Curry–Howard correspondence establishes a deep connection between mathematical proofs and computer programs: propositions are types, proofs are terms, and proof normalization is computation. This correspondence has driven the development of type theory, proof assistants, and programming language design for over fifty years.

Separately, the **tropical semiring** (ℕ, min, +) — where addition is replaced by minimum and multiplication by addition — has emerged as a fundamental structure in combinatorial optimization, algebraic geometry, and theoretical computer science. The Floyd–Warshall and Bellman–Ford shortest-path algorithms, the Viterbi algorithm, and many dynamic programming procedures all operate algebraically over tropical semirings.

This paper bridges these two lines of work. We construct a proof calculus whose semantics is the tropical semiring, making the Curry–Howard correspondence interact with idempotent semiring semantics. In this calculus:

- **Proofs are min-plus programs**: syntax trees with cost-annotated leaves.
- **Cut elimination is optimization**: distributing sequential composition over nondeterministic choice.
- **Normalization computes least cost**: the normal form of a proof term has the same cost as the original, and all normal forms share this cost.
- **Idempotence drives sharing**: the identity min(x, x) = x causes duplicate proof branches to collapse.

### 1.2 Related Work

**Proof theory and rewriting.** Cut elimination was introduced by Gentzen [1935] for sequent calculi and has been extensively studied in the context of linear logic (Girard, 1987), the lambda calculus, and term rewriting systems. Strong normalization proofs via polynomial interpretations are a standard technique in termination analysis (Lankford, 1979; Zantema, 2003).

**Tropical mathematics.** The tropical semiring has been studied in algebraic geometry (Mikhalkin, 2006; Maclagan & Sturmfels, 2015), optimization (Butkovič, 2010), and automata theory (Simon, 1988). The connection between tropical algebra and shortest paths is classical (Gondran & Minoux, 1984).

**Weighted logic and semiring semantics.** Droste & Gastin (2007) developed weighted logics over semirings. Green et al. (2007) introduced semiring provenance for databases. Our work differs in providing a syntactic rewrite system with certified normalization, rather than a denotational semantics.

**Resource-sensitive type theory.** Quantitative type theory (Atkey, 2018; McBride, 2016) assigns resource usage to types. Our tropical proof terms can be viewed as a specialized fragment where the resource algebra is the min-plus semiring.

### 1.3 Contributions

1. A concrete inductive syntax of tropical proof terms (`TropTerm`) with tropical evaluation semantics.
2. A one-step reduction relation (`Step`) capturing idempotence and distributivity, with full congruence closure.
3. A polynomial interpretation (`interp`) that strictly decreases under every reduction step, yielding strong normalization.
4. Machine-verified proofs of soundness, termination, normal form existence, and semantic optimality in Lean 4 with Mathlib.
5. An analysis of confluence, identifying the critical pair that prevents syntactic uniqueness without AC rules for `min`.

---

## 2. Definitions and Notation

### 2.1 Syntax

**Definition 2.1** (Tropical Proof Terms). The set `TropTerm` is defined inductively:

```
t, u, s ::= atom(n)     -- axiom with cost n ∈ ℕ
           | cut(t, s)   -- sequential composition
           | plus(t, s)  -- parallel composition
           | min(t, s)   -- nondeterministic choice
```

We use `DecidableEq` on `TropTerm` (derived by structural equality).

### 2.2 Semantics

**Definition 2.2** (Tropical Evaluation). The evaluation function `eval : TropTerm → ℕ` is:

```
eval(atom(n))   = n
eval(cut(t, s)) = eval(t) + eval(s)
eval(plus(t, s))= eval(t) + eval(s)
eval(min(t, s)) = min(eval(t), eval(s))
```

This maps proof terms into the tropical semiring (ℕ, min, +), where `min` is the semiring addition and `+` is the semiring multiplication.

### 2.3 Reduction Relation

**Definition 2.3** (One-Step Reduction). The relation `Step : TropTerm → TropTerm → Prop` is the compatible closure of three base rules:

| Rule | Name | Redex → Contractum |
|------|------|---------------------|
| (I) | min_idem | min(t, t) → t |
| (D_L) | cut_min_left | cut(min(t, u), s) → min(cut(t, s), cut(u, s)) |
| (D_R) | cut_min_right | cut(s, min(t, u)) → min(cut(s, t), cut(s, u)) |

**Congruence rules**: For each binary constructor `f ∈ {cut, plus, min}`:
- If `Step(t, t')` then `Step(f(t, s), f(t', s))` (left congruence)
- If `Step(s, s')` then `Step(f(t, s), f(t, s'))` (right congruence)

**Definition 2.4** (Normal Form). A term `t` is in normal form, written `Normal(t)`, if there is no `u` with `Step(t, u)`.

### 2.4 Polynomial Interpretation

**Definition 2.5** (Polynomial Interpretation). The function `interp : TropTerm → ℕ` is:

```
interp(atom(_))   = 2
interp(cut(t, s)) = interp(t) · interp(s)
interp(plus(t, s))= interp(t) + interp(s)
interp(min(t, s)) = interp(t) + interp(s) + 1
```

The key property is that `cut` maps to multiplication (which is expansive) while `min` maps to addition + 1 (which is contractive relative to multiplication). This gap drives the termination argument.

---

## 3. Main Results

### 3.1 Soundness of Tropical Cut Elimination

**Theorem 3.1** (Step Preserves Evaluation).
*For all t, u : TropTerm, if Step(t, u) then eval(t) = eval(u).*

*Proof sketch.* By induction on the derivation of `Step(t, u)`.

- **Case (I)**: eval(min(t, t)) = min(eval(t), eval(t)) = eval(t), by idempotence of min on ℕ.
- **Case (D_L)**: eval(cut(min(t, u), s)) = min(eval(t), eval(u)) + eval(s). By the distributive law of addition over min in ℕ: a + min(b, c) = min(a + b, a + c). Hence this equals min(eval(t) + eval(s), eval(u) + eval(s)) = eval(min(cut(t, s), cut(u, s))).
- **Case (D_R)**: Symmetric argument using min(b, c) + a = min(b + a, c + a).
- **Congruence cases**: The inductive hypothesis gives eval equality on the subterm; eval is a congruence for each constructor.  ∎

**Corollary 3.2** (Reflexive-Transitive Closure).
*If Step*(t, u) (reflexive-transitive closure), then eval(t) = eval(u).*

### 3.2 Termination

**Lemma 3.3** (Interpretation Lower Bound).
*For all t : TropTerm, interp(t) ≥ 2.*

*Proof.* By structural induction. atom: interp = 2. cut: interp(t) · interp(s) ≥ 2 · 2 = 4. plus: interp(t) + interp(s) ≥ 4. min: interp(t) + interp(s) + 1 ≥ 5.  ∎

**Theorem 3.4** (Step Decreases Interpretation).
*For all t, u : TropTerm, if Step(t, u) then interp(u) < interp(t).*

*Proof sketch.* By induction on `Step(t, u)`.

- **Case (I)**: interp(min(t, t)) = 2 · interp(t) + 1 > interp(t), since interp(t) ≥ 2.
- **Case (D_L)**: interp(cut(min(t, u), s)) = (interp(t) + interp(u) + 1) · interp(s). The RHS is interp(t) · interp(s) + interp(u) · interp(s) + 1. The difference is interp(s) - 1 ≥ 1 since interp(s) ≥ 2.
- **Case (D_R)**: Symmetric, with difference interp(s) - 1.
- **Congruence under cut**: interp(cut(t', s)) = interp(t') · interp(s) < interp(t) · interp(s) = interp(cut(t, s)), by the IH interp(t') < interp(t) and interp(s) > 0.
- **Congruence under plus/min**: interp(f(t', s)) = interp(t') + interp(s) [+1] < interp(t) + interp(s) [+1] = interp(f(t, s)), by the IH.  ∎

### 3.3 Strong Normalization

**Theorem 3.5** (Strong Normalization).
*Define Reduces(a, b) ≡ Step(b, a). Then Reduces is well-founded: every term t satisfies Acc(Reduces, t).*

*Proof.* By strong induction on interp(t) ∈ ℕ. Given t, for any u with Reduces(u, t) (i.e., Step(t, u)), Theorem 3.4 gives interp(u) < interp(t). By the inductive hypothesis (since interp(u) < interp(t)), Acc(Reduces, u). By the constructor of Acc, Acc(Reduces, t).  ∎

**Corollary 3.6**. WellFounded(Reduces).

### 3.4 Normal Form Existence

**Theorem 3.7** (Normal Form Existence).
*For every t : TropTerm, there exists u with Step*(t, u) and Normal(u).*

*Proof.* By well-founded induction on Reduces (using Theorem 3.5). If t is normal, take u = t. Otherwise, there exists v with Step(t, v). By the inductive hypothesis applied to v (which is accessible since Reduces(v, t)), there exists u with Step*(v, u) and Normal(u). By prepending Step(t, v), we get Step*(t, u).  ∎

### 3.5 Semantic Optimality

**Theorem 3.8** (Semantic Uniqueness of Normal Forms).
*If Step*(t, u) and Normal(u) and Step*(t, v) and Normal(v), then eval(u) = eval(v).*

*Proof.* By Corollary 3.2: eval(u) = eval(t) and eval(v) = eval(t). Hence eval(u) = eval(v).  ∎

This theorem establishes that normalization computes a **unique optimal cost**, even though the normal form may not be syntactically unique.

### 3.6 Confluence Analysis

The rewrite system is **not confluent** (in the strong sense) without additional rules for associativity and commutativity of `min`. The critical pair arises from `cut(min(a, b), min(c, d))`:

- **Path 1** (D_L first): → min(cut(a, min(c,d)), cut(b, min(c,d))) → ... → min(min(cut(a,c), cut(a,d)), min(cut(b,c), cut(b,d)))
- **Path 2** (D_R first): → min(cut(min(a,b), c), cut(min(a,b), d)) → ... → min(min(cut(a,c), cut(b,c)), min(cut(a,d), cut(b,d)))

The final terms are semantically equal (both evaluate to min(a+c, a+d, b+c, b+d)) but syntactically different: the min-branches are grouped differently. Joining these requires associativity and commutativity of `min`.

**Remark.** Semantic uniqueness (Theorem 3.8) suffices for the core application: normalization computes a unique optimal cost. Full syntactic uniqueness requires extending the rewrite system with oriented AC rules for `min`, which is a standard but technically involved extension (see Future Directions).

---

## 4. Algorithms

### 4.1 Tropical Evaluation

```
EVAL(t):
    if t = atom(n): return n
    if t = cut(l, r): return EVAL(l) + EVAL(r)
    if t = plus(l, r): return EVAL(l) + EVAL(r)
    if t = min(l, r): return min(EVAL(l), EVAL(r))
```

**Complexity:** O(n) time, O(d) space (where n = |t|, d = depth).

### 4.2 Polynomial Interpretation

```
INTERP(t):
    if t = atom(_): return 2
    if t = cut(l, r): return INTERP(l) * INTERP(r)
    if t = plus(l, r): return INTERP(l) + INTERP(r)
    if t = min(l, r): return INTERP(l) + INTERP(r) + 1
```

**Complexity:** O(n) time, O(d) space.

### 4.3 Leftmost-Outermost Reduction

```
STEP(t):
    if t = min(l, r) and l = r: return l
    if t = cut(min(a,b), s): return min(cut(a,s), cut(b,s))
    if t = cut(s, min(a,b)): return min(cut(s,a), cut(s,b))
    if t ≠ atom:
        l' = STEP(t.left)
        if l' ≠ None: return t with left = l'
        r' = STEP(t.right)
        if r' ≠ None: return t with right = r'
    return None
```

**Complexity:** O(n) per step.

### 4.4 Full Normalization

```
NORMALIZE(t):
    while STEP(t) ≠ None:
        t = STEP(t)
    return t
```

**Termination:** Guaranteed by Theorem 3.4 (each step decreases interp(t) ∈ ℕ).

**Worst-case complexity:** O(interp(t)) steps, each O(n) time. Since interp can be exponential in term size (due to multiplication in the cut case), the worst case is exponential. For terms with bounded cut-nesting depth, normalization is polynomial.

---

## 5. Applications

### 5.1 Shortest Paths

A weighted directed graph G = (V, E, w) can be encoded as a tropical proof term:
- Each edge (u, v) with weight w becomes `atom(w)`.
- Sequential edges become `cut` (costs add).
- Alternative paths become `min` (costs take minimum).

Normalizing the proof term computes the shortest path cost. This is the tropical Curry–Howard interpretation of the Bellman–Ford algorithm.

### 5.2 Task Scheduling

A pipeline of tasks with alternative implementations at each stage can be modeled as `cut(min(impl1, impl2, ...), min(impl1', impl2', ...))`. Normalization distributes the stages and finds the optimal schedule.

### 5.3 Proof Compression

Duplicate proof branches (arising from lemma reuse) are represented as `min(P, P)`. Idempotent collapse reduces this to `P`, achieving proof sharing. For proofs with k levels of duplication, compression achieves a 2^k : 1 ratio.

---

## 6. Computational Experiments

We implemented the algorithms in Python and ran experiments on synthetic proof terms.

| Term | Size | Cost | Interp | Steps | Normal Size |
|------|------|------|--------|-------|-------------|
| cut(min(a(1),a(3)), min(a(2),a(4))) | 7 | 3 | 25 | 3 | 15 |
| min(min(a(7),a(7)), min(a(7),a(7))) | 7 | 7 | 11 | 2 | 1 |
| cut(min(cut(min(a(1),a(2)),a(3)),a(2)), min(a(1),a(3))) | 11 | 3 | 65 | 7 | 31 |

Key observations:
- Cost is always preserved (Theorem 3.1).
- Interpretation strictly decreases at each step (Theorem 3.4).
- Normal form size can exceed input size (distribution duplicates subterms).
- Idempotent collapse can dramatically reduce size (7 → 1 in the second example).

---

## 7. Discussion

### 7.1 Strengths

The tropical Curry–Howard correspondence provides:
- A **unified framework** connecting proof theory, tropical algebra, and combinatorial optimization.
- **Machine-verified** foundational results, providing the highest level of certainty.
- **Executable algorithms** extracted from the formal development.
- A **clean separation** of syntax (proof terms), semantics (tropical evaluation), and metatheory (normalization).

### 7.2 Limitations

- **Confluence gap**: Without AC rules for `min`, normal forms are not syntactically unique. This is a known issue in rewriting theory and has standard solutions (ordered rewriting, canonical representatives).
- **Exponential blowup**: Distribution can exponentially increase term size, mirroring the behavior of classical cut elimination. This is inherent to the problem and cannot be avoided in general.
- **Limited expressiveness**: The current calculus has no variables, abstraction, or higher-order features. It is a first-order term rewriting system, not a full programming language.

### 7.3 Open Questions

1. Does the extended system with oriented AC rules for `min` have a polynomial-time normalization procedure for bounded-depth terms?
2. Is there a linear-time algorithm for computing the eval of the normal form without constructing it?
3. Can the polynomial interpretation be extended to handle a typed tropical lambda calculus?
4. What is the precise relationship between tropical proof normal forms and Newton polytopes of tropical polynomials?

---

## 8. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps. The most promising directions are:

1. **Typed tropical lambda calculus** with cost-aware β-reduction.
2. **Confluence via canonical forms** using sorted, deduplicated min-lists.
3. **Completeness against DAG path algebras**, establishing the formal bridge to shortest-path computation.
4. **Tropical linear logic**, connecting to resource-sensitive type systems.
5. **Certified proof search algorithms** with complexity bounds.

---

## 9. References

- Atkey, R. (2018). Syntax and semantics of quantitative type theory. *LICS*.
- Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms*. Springer.
- Curry, H. B. (1934). Functionality in combinatory logic. *Proc. Nat. Acad. Sci.*, 20(11), 584–590.
- Droste, M., & Gastin, P. (2007). Weighted automata and weighted logics. *TCS*, 380(1-2), 69–86.
- Gentzen, G. (1935). Untersuchungen über das logische Schließen. *Math. Zeitschrift*, 39, 176–210, 405–431.
- Girard, J.-Y. (1987). Linear logic. *TCS*, 50(1), 1–101.
- Gondran, M., & Minoux, M. (1984). *Graphs and Algorithms*. Wiley.
- Green, T. J., et al. (2007). Provenance semirings. *PODS*.
- Howard, W. A. (1980). The formulae-as-types notion of construction. In *To H. B. Curry: Essays on Combinatory Logic*.
- Lankford, D. S. (1979). On proving term rewriting systems are Noetherian. Technical report.
- Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
- Mikhalkin, G. (2006). Tropical geometry and its applications. *ICM Proceedings*.
- Simon, I. (1988). Recognizable sets with multiplicities in the tropical semiring. *MFCS*.
- Zantema, H. (2003). Termination. In *Term Rewriting Systems*, Cambridge UP.

---

## Appendix: Lean 4 Formalization

The complete formalization is in `Logic/TropicalCurryHoward.lean`. Key declarations:

```lean
-- Syntax
inductive TropTerm where
  | atom | cut | plus | min

-- Semantics
def eval : TropTerm → Nat

-- Reduction
inductive Step : TropTerm → TropTerm → Prop

-- Main theorems
theorem step_preserves_eval : Step t u → eval t = eval u
theorem step_decreases_interp : Step t u → interp u < interp t
theorem acc_step : ∀ t, Acc Reduces t
theorem strongly_normalizing : WellFounded Reduces
theorem normal_form_exists : ∀ t, ∃ u, Step* t u ∧ Normal u
theorem normal_forms_eval_eq : Step* t u → Normal u → Step* t v → Normal v → eval u = eval v
```

All proofs compile with zero `sorry` and depend only on standard axioms (`propext`, `Classical.choice`, `Quot.sound`).
