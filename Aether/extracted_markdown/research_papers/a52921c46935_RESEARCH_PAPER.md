# Generation Certificates for Matrix Groups: Irreducible Characteristic Polynomials as Structural Witnesses

## Abstract

We develop a certificate-based framework that turns an *algebraic*
property of a single linear map — irreducibility of its characteristic
polynomial — into a *structural* witness for the absence of invariant
subspaces, and hence into a building block for probabilistic generation
of finite linear groups. The central result is an **irreducible action
theorem**: a finite-dimensional endomorphism whose characteristic
polynomial is irreducible admits no proper nonzero invariant subspace.
We derive two consequences of independent interest — an **orbit-spanning
theorem** bridging to the theory of linear feedback shift registers and
cyclic codes, and a **no-fixed-flat theorem** characterizing Singer
cycles in finite projective geometry — together with a quantitative
**positive-density** principle that underpins probabilistic generation
arguments. We give a uniform abstract formulation, the *generation
certificate system*, that subsumes the classical symmetric-group story
of Dixon and the linear case under a single pattern. All principal
results are formally verified; we record the proof strategy (via the
minimal polynomial and the Cayley–Hamilton theorem) in full and state
the remaining quantitative refinements as precise conjectures.

**Keywords:** matrix groups, characteristic polynomial, irreducibility,
invariant subspace, Singer cycle, group generation, minimal polynomial,
Cayley–Hamilton, finite fields, probabilistic generation.

---

## 1. Introduction

A recurring problem in computational and theoretical group theory is to
certify, cheaply and reliably, that a small set of elements generates a
large group. For the symmetric groups `Sₙ`, Dixon (1969) proved that two
uniformly random permutations generate `Sₙ` or `Aₙ` with probability
tending to `1` as `n → ∞`; this result is the theoretical justification
for the random-generation heuristics in computational algebra systems.

For *linear groups* — subgroups of `GL(V)` for a finite-dimensional
vector space `V` over a finite field — the analogous statements are
harder, because matrices carry rich internal structure. The principal
obstruction to generation is the existence of a **common invariant
subspace**: a proper nonzero subspace preserved by all the candidate
generators. Any subgroup that fixes such a subspace is contained in a
proper parabolic-type subgroup and cannot be the full general linear
group.

This paper isolates the precise algebraic feature of a single element
that rules out invariant subspaces, packages it as a *generation
certificate*, and assembles the surrounding theory:

1. an **irreducible action theorem** (Theorem 4.1): irreducibility of
   the characteristic polynomial implies no proper nonzero invariant
   subspace;
2. an **orbit-spanning theorem** (Theorem 5.1) linking to LFSRs and
   cyclic codes;
3. a **no-fixed-flat theorem** (Theorem 6.1) describing Singer cycles;
4. a **positive-density** principle (Theorem 7.1) and an abstract
   **generation certificate system** (Definition 3.4).

We work over an arbitrary field for the structural results and
specialize to prime fields `ℤ/pℤ` for the computational instances.

---

## 2. Preliminaries and notation

Throughout, `K` is a field and `V` a finite-dimensional `K`-vector
space. We write `End_K(V)` for the `K`-algebra of linear endomorphisms
of `V`, and for `φ ∈ End_K(V)`:

- `charpoly(φ) ∈ K[X]` is the characteristic polynomial, a monic
  polynomial of degree `dim_K V`;
- `minpoly_K(φ) ∈ K[X]` is the minimal polynomial, the monic generator
  of the annihilator ideal `{p ∈ K[X] : p(φ) = 0}`;
- for a polynomial `p` and an endomorphism `φ`, `aeval_φ(p) = p(φ)`
  denotes the algebra evaluation of `p` at `φ`.

We use two classical facts without reproof.

**Cayley–Hamilton.** For every `φ ∈ End_K(V)`, `charpoly(φ)(φ) = 0`;
equivalently `minpoly_K(φ) ∣ charpoly(φ)`.

**Degree of charpoly.** `deg charpoly(φ) = dim_K V`, and `charpoly(φ)` is
monic (hence nonzero).

Recall that `p ∈ K[X]` is **irreducible** if it is not a unit and
whenever `p = ab` one of `a, b` is a unit. Over a field, the units of
`K[X]` are exactly the nonzero constants, so an irreducible polynomial
has positive degree and no factorization into two positive-degree
polynomials.

---

## 3. Core definitions

### Definition 3.1 (Invariant submodule)

A submodule (subspace) `W ⊆ V` is **invariant** under `φ ∈ End_K(V)`,
written `IsInvariantSubmodule φ W`, if
```
∀ w ∈ W,  φ(w) ∈ W.
```
Equivalently, `W` is a `K[X]`-submodule of `V` under the module
structure in which `X` acts as `φ`. The lattice of `φ`-invariant
subspaces is the lattice of these submodules; `⊥ = {0}` and `⊤ = V` are
always invariant. We call `φ` **irreducible** (as an action) if its only
invariant subspaces are `⊥` and `⊤`.

### Definition 3.2 (Linear generation certificate)

A **linear generation certificate** for a finite free `K`-module `V`
is a triple
```
( φ : End_K(V),  invertible : Bijective φ,  charpoly_irreducible : Irreducible (charpoly φ) ).
```
That is, a bijective endomorphism whose characteristic polynomial is
irreducible. The certificate is a small datum (the matrix of `φ` plus a
verified factorization-free polynomial) whose validity is decidable in
polynomial time over a finite field.

### Definition 3.3 (Certificate density)

For a finite group `G` and a decidable predicate `C : G → Prop`, the
**certificate density** is the rational number
```
certificateDensity(C) = #{ g ∈ G : C(g) } / #G ∈ ℚ,
```
the probability that a uniformly random element of `G` satisfies `C`.

### Definition 3.4 (Generation certificate system)

A **generation certificate system** on a group `G` is a predicate
`Cert : G → Prop` together with the guarantee
```
∀ g, Cert(g) → ∀ H ≤ G, g ∈ H → (H = G  ∨  [G : H] ≤ 2),
```
i.e. any subgroup containing a certified element is the whole group or
has index at most two. This abstracts the common shape of the
symmetric-group certificate (a permutation of prime-cycle type forcing
`Aₙ`-or-`Sₙ`) and the linear certificate developed below.

---

## 4. The irreducible action theorem

The structural heart of the framework is the following.

### Theorem 4.1 (Irreducible action)

Let `V` be finite-dimensional over `K` and `φ ∈ End_K(V)` with
`charpoly(φ)` irreducible. Then every `φ`-invariant subspace `W ⊆ V`
satisfies `W = ⊥` or `W = ⊤`.

The proof rests on three lemmas about restrictions of `φ` to invariant
subspaces. For an invariant `W`, let `φ|_W ∈ End_K(W)` denote the
restriction, characterized by the intertwining relation
`ι_W ∘ φ|_W = φ ∘ ι_W`, where `ι_W : W ↪ V` is the inclusion.

#### Lemma 4.2 (Restriction intertwines)

For invariant `W`, `ι_W ∘ φ|_W = φ ∘ ι_W` as maps `W → V`.

*Proof sketch.* By definition of the restriction, evaluating both sides
at `w ∈ W` gives `φ(w)` on the nose; the equality is the very statement
that `φ|_W` is the corestriction of `φ ∘ ι_W` through the invariance
hypothesis. ∎

#### Lemma 4.3 (Annihilators descend to restrictions)

If `p ∈ K[X]` satisfies `p(φ) = 0`, then `p(φ|_W) = 0`.

*Proof sketch.* From Lemma 4.2 one shows by induction on `m` that
`(φ|_W)^m = ` restriction of `φ^m`, i.e. `ι_W ∘ (φ|_W)^m = φ^m ∘ ι_W`.
Writing `p = Σ aₘ Xᵐ` and using linearity, `ι_W ∘ p(φ|_W) = p(φ) ∘ ι_W
= 0`. Since `ι_W` is injective, `p(φ|_W) = 0`. ∎

#### Lemma 4.4 (Minimal polynomial divides)

`minpoly_K(φ|_W) ∣ minpoly_K(φ)`.

*Proof sketch.* `minpoly_K(φ)(φ) = 0` by definition, so by Lemma 4.3
`minpoly_K(φ)(φ|_W) = 0`; hence `minpoly_K(φ)` lies in the annihilator
ideal of `φ|_W`, which is generated by `minpoly_K(φ|_W)`. Thus
`minpoly_K(φ|_W) ∣ minpoly_K(φ)`. ∎

#### Lemma 4.5 (Minimal equals characteristic under irreducibility)

If `charpoly(φ)` is irreducible then `minpoly_K(φ) = charpoly(φ)`.

*Proof sketch.* By Cayley–Hamilton `minpoly_K(φ) ∣ charpoly(φ)`. An
irreducible monic polynomial has, up to units, only the divisors `1` and
itself; the minimal polynomial is monic and nonconstant on a nonzero
space, so `minpoly_K(φ) = charpoly(φ)`. (The degenerate case `V = 0` is
vacuous: there is no irreducible degree-`0` polynomial, so the
hypothesis cannot hold; in the formalization this is handled by a direct
case split on `dim V ∈ {0, 1, ≥2}`.) ∎

#### Proof of Theorem 4.1

Let `W` be invariant and suppose `W ≠ ⊥`; we show `W = ⊤`. Apply the
lemmas to `φ|_W`:

- By Lemma 4.4 and Cayley–Hamilton for `φ`,
  `minpoly_K(φ|_W) ∣ minpoly_K(φ) ∣ charpoly(φ)`.
- `minpoly_K(φ|_W) ≠ 1`: otherwise `id_W = 1(φ|_W) = 0`, forcing
  `W = ⊥`, contrary to assumption.
- Since `charpoly(φ)` is irreducible and `minpoly_K(φ|_W)` is a
  nonconstant monic divisor, `minpoly_K(φ|_W) = charpoly(φ)`.

Now compare dimensions. On one hand,
`deg minpoly_K(φ|_W) ≤ deg charpoly(φ|_W) = dim_K W`. On the other,
`deg minpoly_K(φ|_W) = deg charpoly(φ) = dim_K V`. Hence
`dim_K V ≤ dim_K W ≤ dim_K V`, so `dim_K W = dim_K V` and therefore
`W = ⊤`. ∎

The argument never enumerates subspaces; it is a finite computation on
polynomial degrees, which is why it scales to arbitrary dimension.

---

## 5. Orbit spanning: the coding-theory bridge

### Lemma 5.1 (Orbit span is invariant)

For any `φ ∈ End_K(V)` and `v ∈ V`, the subspace
`span_K { φ^m v : m ∈ ℕ }` is `φ`-invariant.

*Proof sketch.* `φ` maps the generator `φ^m v` to `φ^{m+1} v`, again a
generator; invariance of the span follows from linearity and the
universal property of span. ∎

### Theorem 5.2 (Orbit spanning)

If `charpoly(φ)` is irreducible and `v ≠ 0`, then
```
span_K { v, φv, φ²v, φ³v, … } = V.
```

*Proof sketch.* By Lemma 5.1 the orbit span `U` is invariant; it is
nonzero because `v ∈ U` and `v ≠ 0`. By Theorem 4.1, `U = ⊥` or `U = ⊤`;
nonzeroness rules out `⊥`, so `U = ⊤ = V`. ∎

**Interpretation.** This is the algebraic backbone of **linear feedback
shift registers** (LFSRs) and **cyclic codes**. Identify `V ≅ K[X]/(f)`
with `f = charpoly(φ)` and `φ` the multiplication-by-`X` (companion)
operator. Theorem 5.2 says the state sequence `v, φv, φ²v, …` of an LFSR
with irreducible feedback polynomial visits a spanning set of states; in
the finite-field case this is exactly the *maximal-length* (m-sequence)
property when `X` additionally generates the multiplicative group of the
extension field. Cyclic codes arise as the `φ`-invariant subspaces of
`K[X]/(X^n - 1)`; irreducibility of relevant factors controls the
minimal ideals (the irreducible/minimal cyclic codes).

---

## 6. Finite geometry: Singer cycles

### Theorem 6.1 (No fixed proper projective subspace)

If `charpoly(φ)` is irreducible, there is no subspace `W` with
`W ≠ ⊥`, `W ≠ ⊤`, and `IsInvariantSubmodule φ W`.

*Proof sketch.* Immediate from Theorem 4.1: any invariant `W` is `⊥` or
`⊤`, so the conjunction `W ≠ ⊥ ∧ W ≠ ⊤ ∧ invariant` is contradictory. ∎

**Interpretation.** Passing to the projective space `PG(n-1, q)` of lines
in `V = 𝔽_q^n`, a proper nonzero invariant subspace is precisely a fixed
proper projective flat (point, line, plane, …). Theorem 6.1 says an
endomorphism with irreducible characteristic polynomial fixes no proper
flat. When `φ` has order `q^n − 1` (its eigenvalue is a primitive element
of `𝔽_{q^n}`), it is a **Singer cycle**: a cyclic collineation that
permutes the `(q^n − 1)/(q − 1)` points of `PG(n-1, q)` in a single
orbit. Singer cycles are the source of cyclic projective planes, perfect
difference sets (Singer difference sets), and many combinatorial designs;
Theorem 6.1 is the structural reason for their maximal transitivity.

---

## 7. From elements to groups: density and the abstract system

### Theorem 7.1 (Positive certificate density)

Let `G` be a finite group and `C : G → Prop` a decidable predicate with
at least one witness (`∃ g, C(g)`). Then `certificateDensity(C) > 0`.

*Proof sketch.* The numerator `#{ g : C(g) }` is positive because the
subtype `{ g // C(g) }` is inhabited by the witness; the denominator
`#G ≥ 1` because `G` contains the identity. A positive rational divided
by a positive rational is positive. ∎

Though elementary, Theorem 7.1 is the indispensable base case of every
probabilistic generation argument: *existence* of certified elements
upgrades to a *positive probability* of sampling one, which is what makes
random search succeed and what one then quantifies.

### Specialization 7.2 (Prime-field Singer certificate)

For `V` finite-dimensional over `K = ℤ/pℤ` (`p` prime) and
`φ ∈ End(V)` with `charpoly(φ)` irreducible, every invariant subspace is
`⊥` or `⊤`. This is the direct instantiation of Theorem 4.1 used in
computational group theory, where matrices are stored over prime fields
and characteristic-polynomial irreducibility is tested by Berlekamp's
algorithm.

### The unifying pattern

Definition 3.4 packages the shared logic of the symmetric and linear
cases: a predicate that forces any subgroup containing a certified
element to be the whole group (or index ≤ 2, accommodating the
`Aₙ`-vs-`Sₙ` dichotomy). In the linear setting the certificate predicate
is "irreducible characteristic polynomial", whose structural payoff is
Theorem 4.1; combined with a second random element controlling the
determinant, it drives generation of `GL(V)` / `SL(V)`.

---

## 8. Algorithms

The framework is constructive over finite fields. Two procedures are
central.

### 8.1 Certificate verification

**Input:** a matrix `M ∈ 𝔽_q^{n×n}`. **Output:** `valid` iff `M` is a
linear generation certificate.

```
1. Compute d = det(M); if d = 0, return invalid (not bijective).
2. Compute p(X) = charpoly(M) ∈ 𝔽_q[X]  (e.g. Faddeev–LeVerrier or
   Hessenberg method), an O(n³) field-operation computation.
3. Test irreducibility of p over 𝔽_q (Rabin's test: p ∣ X^{q^n} − X and
   gcd(p, X^{q^{n/ℓ}} − X) = 1 for each prime ℓ ∣ n), O(n³ log q).
4. Return valid iff p is irreducible.
```

The whole test is polynomial time; the expensive geometric property
(no invariant subspace) is certified for free by Theorem 4.1.

### 8.2 Invariant-subspace audit (validation)

To *empirically* corroborate Theorem 4.1 on small instances, enumerate
all subspaces of `𝔽_q^n` (via reduced row-echelon representatives) and
check invariance of each under `M`; confirm that only `{0}` and the full
space survive whenever `charpoly(M)` is irreducible. This is exponential
in `n` and used only as a test oracle, not in production.

### 8.3 Density estimation

Enumerate or sample `GL_n(𝔽_q)`, count the fraction with irreducible
characteristic polynomial, and compare against the heuristic `≈ 1/n`
(the proportion of degree-`n` polynomials over `𝔽_q` that are
irreducible is `≈ 1/n` by the prime-polynomial theorem, and the bijection
between separable irreducible charpolys and their companion conjugacy
classes makes this the right first-order estimate).

---

## 9. Applications

- **Computational group theory.** Random matrices with irreducible
  charpoly are the preferred seeds for constructive recognition of
  classical groups (Neumann–Praeger). Theorem 4.1 certifies their
  irreducible action; Theorem 7.1 launches the probabilistic counting.
- **Cryptography.** Maximal-length LFSRs (Theorem 5.2) generate the
  keystream of stream ciphers and the spreading codes of CDMA/GPS; the
  irreducibility certificate guarantees the maximal period.
- **Coding theory.** Minimal cyclic codes correspond to irreducible
  factors of `X^n − 1`; the invariant-subspace correspondence (Section 5)
  is the module-theoretic foundation of the code decomposition.
- **Finite geometry & design theory.** Singer cycles (Theorem 6.1)
  furnish cyclic projective planes and Singer difference sets.

---

## 10. Discussion

The methodological message is the substitution of an exponential
geometric search (enumerate invariant subspaces) by a polynomial
algebraic test (factor one polynomial). The bridge is Theorem 4.1, whose
proof is purely about polynomial degrees and divisibility — no subspace
is ever inspected. This robustness is why the result holds over an
arbitrary field and specializes cleanly to the finite-field instances
that matter computationally.

The abstract generation certificate system (Definition 3.4) makes
explicit that the symmetric-group and matrix-group generation theories
are two readings of one template. This is more than cosmetic: it suggests
a uniform interface in which a "certificate" is any cheaply checkable
predicate with a proven structural consequence, and a "generation
theorem" is a density bound on certified elements.

---

## 11. Future work and conjectures

Two quantitative refinements remain open.

### Conjecture A (Linear certificate density lower bound)

For fixed prime power `q` and growing `n`,
```
#{ Singer certificates in GL_n(𝔽_q) } / #GL_n(𝔽_q)  ≥  c_q / n
```
for a constant `c_q > 0`. Heuristically the proportion of monic
degree-`n` irreducible polynomials over `𝔽_q` is `~ 1/n`, and almost all
such polynomials are separable and realized as characteristic polynomials
of regular semisimple (cyclic-action) matrices; making the lower bound
rigorous and uniform in `q` is the goal.

### Conjecture B (Two-generator sufficiency)

For random `g, h ∈ GL_n(𝔽_q)`, if `g` has irreducible characteristic
polynomial and `det(h)` generates `𝔽_q^×`, then
```
Pr[ ⟨g, h⟩ = GL_n(𝔽_q) ]  ≥  1 − O(q^{-1}).
```
This is the linear analogue of Dixon's theorem and the practical
justification for certificate-seeded random generation.

Further directions include: a meet-side analysis of the invariant
subspace lattice; quantitative orbit-length statistics for non-Singer
irreducible elements; and extending the certificate system to the
remaining classical groups (symplectic, orthogonal, unitary) where the
relevant structural witness combines charpoly irreducibility with a
preserved bilinear form.

---

## 12. Conclusion

A single unfactorable polynomial certifies an entire group-theoretic
phenomenon. Irreducibility of the characteristic polynomial — decidable
in polynomial time — implies the complete absence of invariant subspaces
(Theorem 4.1), which in turn yields maximal-length orbits (Theorem 5.2),
transitive Singer actions in finite geometry (Theorem 6.1), and, through
positive certificate density (Theorem 7.1), the probabilistic generation
of matrix groups. The framework's value lies in trading an impossible
search for a fast algebraic check, with a verified proof guaranteeing the
trade is sound.

---

## References

- Dixon, J. D. (1969). *The probability of generating the symmetric
  group.* Mathematische Zeitschrift, 110, 199–205.
- Huppert, B. (1967). *Endliche Gruppen I.* Springer.
- Neumann, P. M., Praeger, C. E. (1992). *A recognition algorithm for
  special linear groups.* Proc. London Math. Soc., 65(3), 555–603.
