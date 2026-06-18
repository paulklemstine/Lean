# Future Directions: Derivative Growth and Semantic Depth

## Five Testable Conjectures for the Next Research Cycle

---

### Conjecture 1: Sharp Depth Envelope with Polynomial Correction

**Precise Statement.** There exists a universal polynomial *P* such that for every exp-fragment expression *E* with SubexprBoundedOn(*E*, *M*) and *M* ≥ 1:

$$\max_{x \in [0,1]} |E'(x)| \leq P(|E|) \cdot \text{iterExp}(\text{depth}(E), M)$$

and for infinitely many depths *d*, there exists *E_d* with depth(*E_d*) = *d* such that:

$$\max_{x \in [0,1]} |E_d'(x)| \geq c \cdot \text{iterExp}(d, 1)$$

for some universal constant *c* > 0.

**Test.** Enumerate all exp-fragment expressions of size ≤ 20 and depth ≤ 5. For each, compute the ratio R(E) = max|E'| / iterExp(depth(E), M). If R(E) grows superpolynomially in |E| for some family, the conjecture is false. If R(E) is bounded by |E|^k for some fixed k across all experiments, the conjecture is supported.

**Impact.** If true, this establishes that the tower majorant is tight up to an expressible overhead, making the depth invariant quantitatively precise. It would reduce the depth detection problem to estimating a single ratio.

---

### Conjecture 2: Depth Identifiability from Derivative Profile

**Precise Statement.** For bounded-coefficient exp-fragment expressions (constants in [-C, C] for fixed *C*), the minimal representation depth is recoverable up to ±1 from the asymptotic growth class of the derivative envelope on [0,1].

More precisely: define the *derivative growth class* of a function *f* on [0,1] as the unique *d* ∈ ℕ such that:

$$\text{iterExp}(d-1, M) < \max_{x \in [0,1]} |f'(x)| \leq \text{iterExp}(d, M)$$

for some *M* depending only on *f*. Then for any two exp-fragment expressions *E₁*, *E₂* with the same evaluation on [0,1], their depth growth classes differ by at most 1.

**Refutation Criterion.** Find two extensionally equal functions with minimal depths *d₁* and *d₂* where |*d₁* - *d₂*| ≥ 2 but identical derivative envelopes. Alternatively, find an expression where the derivative growth class underestimates the true depth by ≥ 2.

**Impact.** If true, this would make depth a *detectable* invariant: given black-box access to a function, one could infer its representation depth from derivative measurements alone.

---

### Conjecture 3: Extension to the Full Expression Language

**Precise Statement.** The depth majorant theorem extends to the full expression language (var, const, add, mul, exp, div, log) with the following modification: for expressions with division and logarithm, the derivative bound takes the form:

$$|E'(x)| \leq \text{iterExp}(\text{depth}(E), M) \cdot \left(\frac{M}{\delta}\right)^{s(E)}$$

where *δ* = min{|E_sub(x)| : E_sub is a denominator subexpression} and *s(E)* is the number of division nodes.

**Test.** Formalize the extended bound in the proof system. Alternatively, generate random full-language expressions and check whether the modified bound holds numerically on a fine grid.

**Impact.** Extending beyond the exp-fragment would make the theory applicable to the full language of elementary analysis, connecting to symbolic computation and computer algebra systems.

---

### Conjecture 4: Higher Derivatives and Gevrey Classes

**Precise Statement.** For exp-fragment expressions of depth *d* with SubexprBoundedOn(*E*, *M*), the *n*-th derivative satisfies:

$$|E^{(n)}(x)| \leq C(n, |E|) \cdot \text{iterExp}(d, M)^n$$

for some function *C* polynomial in *n* and |*E*|. In particular, depth-*d* expressions belong to the Gevrey class *G^s* for *s* depending on *d*:

$$|E^{(n)}(x)| \leq A \cdot B^n \cdot (n!)^s$$

with *s* = *s(d)* decreasing toward 1 as *d* → ∞.

**Test.** Numerically compute higher derivatives (n = 1, ..., 20) of tower expressions at x = 0.5 using automatic differentiation. Fit the growth pattern to Gevrey classes. Check whether the Gevrey index correlates with depth.

**Impact.** This would connect expression depth to regularity theory, placing compositional complexity within the framework of Gevrey and ultraholomorphic function classes. It could also connect to the theory of resurgent functions and Borel summability.

---

### Conjecture 5: Ordinal-Indexed Depth and Fast-Growing Hierarchies

**Precise Statement.** Define the *α*-iterated exponential for ordinals *α* < ε₀ using the fast-growing hierarchy:

$$f_0(x) = x + 1, \quad f_{\alpha+1}(x) = f_\alpha^{(x)}(x), \quad f_\lambda(x) = f_{\lambda[x]}(x)$$

The derivative growth of *f_α* on [0,1] is bounded by *f_{α+1}(M)* and witnesses *f_α(M)*.

**Conjecture.** For the natural extension of the expression language to transfinite compositions (via recursion schemes), derivative growth classifies expressions into levels of the fast-growing hierarchy. Specifically, an expression whose derivative growth is in the class of *f_α* cannot be represented by a recursion scheme of ordinal rank < *α*.

**Test.** Formalize the fast-growing hierarchy in the proof system. Prove the base case: depth-*d* expressions correspond to level *d* (which is the finite case of the current theory). Then test whether Ackermann-type recursions produce derivative growth at level *ω*.

**Impact.** This would place expression complexity theory in contact with proof-theoretic ordinals and subrecursive hierarchies, potentially creating a bridge between computational complexity and proof theory. The derivative would become a semantic witness for proof-theoretic strength.

---

## Summary Table

| # | Conjecture | Status | Test Type | Difficulty |
|---|-----------|--------|-----------|------------|
| 1 | Sharp polynomial correction | Open | Computational enumeration | Medium |
| 2 | Depth identifiability | Open | Counterexample search | Medium |
| 3 | Full language extension | Open | Formal proof + numerics | High |
| 4 | Higher derivatives / Gevrey | Open | Numerical AD + fitting | Medium |
| 5 | Ordinal hierarchy connection | Speculative | Formal proof | Very High |

Each conjecture is falsifiable: Conjectures 1–2 can be refuted by explicit counterexamples, Conjecture 3 by a single unbounded expression, Conjecture 4 by a depth-growth mismatch in Gevrey indices, and Conjecture 5 by a recursion scheme whose derivative growth violates the ordinal classification.
