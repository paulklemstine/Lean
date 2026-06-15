# Generation Certificates for Matrix Groups: Irreducible Characteristic Polynomials as Structural Witnesses

## Abstract

We develop a certificate-based framework for reasoning about the generation of
linear groups over finite fields, centered on a single, computationally cheap,
algebraic invariant: the irreducibility of the characteristic polynomial of a
linear endomorphism. The framework rests on a structural backbone theorem — that
an endomorphism with irreducible characteristic polynomial admits no nontrivial
invariant subspace — from which we derive three cross-domain consequences: an
orbit-spanning theorem connecting to coding theory and linear feedback shift
registers; a fixed-flat-freeness theorem connecting to finite projective
geometry and Singer cycles; and a generation-density positivity result that
furnishes the quantitative foundation for probabilistic generation arguments in
the spirit of Dixon and Neumann–Praeger. We isolate the common abstract pattern
shared by symmetric-group and linear-group generation in a single
`GenerationCertificateSystem` interface. All structural results stated here have
been formalized and machine-verified; we present them with complete mathematical
statements and proof sketches, together with algorithms, numerical
demonstrations, and a discussion of the remaining quantitative conjectures.

**Keywords:** general linear group, characteristic polynomial, irreducibility,
invariant subspace, minimal polynomial, Singer cycle, group generation, finite
fields, Cayley–Hamilton, coding theory.

---

## 1. Introduction

### 1.1 The generation problem

Let `G` be a finite group. The *generation problem* asks for elements
`g₁, ..., g_k ∈ G` such that the smallest subgroup containing them is `G` itself.
For the enormous groups that arise in computational algebra — symmetric groups
`S_n` and matrix groups `GL_n(𝔽_q)` whose orders dwarf any explicit
enumeration — the practical answer is *randomized*: select elements at random and
test whether they generate. The theoretical justification for this practice is a
family of theorems guaranteeing that random elements generate with high
probability.

The foundational result is due to Dixon (1969): two random elements of `S_n`
generate either `S_n` or `A_n` with probability tending to `1`. The linear
analogue — that two random elements of a classical group generate it with high
probability — was established by Neumann and Praeger (1992) and underlies the
recognition algorithms in systems such as GAP and Magma.

### 1.2 From probability to certificates

A recurring theme in these arguments is the identification of a *structural
property* of elements that (i) is computationally cheap to verify, (ii) holds
with positive (indeed asymptotically substantial) density, and (iii) forces any
subgroup containing such an element to be very large. We call an element with
such a property *certified*, and we call the property a *generation certificate*.

For the linear case, the natural certificate is the **irreducibility of the
characteristic polynomial**. Computing a characteristic polynomial and testing
its irreducibility over a finite field are classical polynomial-time procedures.
This paper makes precise, and machine-verifies, the structural payoff of that
certificate: an element so certified acts *irreducibly* on the underlying vector
space, with all the consequences that entails for generation, transitivity, and
orbit structure.

### 1.3 Contributions

1. A formal definition of invariance, linear generation certificates,
   certificate density, and an abstract generation-certificate system
   (Section 2).
2. The **Irreducible Action Theorem** (Theorem 4.1): irreducible characteristic
   polynomial ⟹ every invariant submodule is `⊥` or `⊤`, with a self-contained
   proof via the minimal polynomial (Section 3–4).
3. Three cross-domain corollaries — orbit spanning (Theorem 5.1), absence of
   fixed proper flats (Theorem 5.2), and the Singer-cycle specialization
   (Theorem 5.3).
4. The **Generation Lower Bound** (Theorem 6.1): positivity of certificate
   density, the quantitative entry point.
5. The abstract `GenerationCertificateSystem` interface unifying the symmetric
   and linear cases (Section 7), and two precise quantitative conjectures
   (Section 9).

---

## 2. Definitions

Throughout, `K` denotes a field, `V` a `K`-vector space, and
`φ : V → V` a `K`-linear endomorphism, written `φ ∈ End_K(V)`. When finiteness
is needed we assume `V` is finite-dimensional. We write `charpoly(φ)` for the
characteristic polynomial and `minpoly_K(φ)` for the minimal polynomial of `φ`
over `K`.

**Definition 2.1 (Invariant submodule).** A submodule `W ⊆ V` is *invariant*
under `φ`, written `IsInvariantSubmodule φ W`, if
```
∀ w ∈ W,  φ(w) ∈ W.
```
Equivalently, `W` is a `K[X]`-submodule of `V` under the `K[X]`-module structure
in which `X` acts as `φ`.

**Definition 2.2 (Linear generation certificate).** A *linear generation
certificate* for a finite-dimensional free module `V` over `K` is a triple
```
⟨ φ,  hbij,  hirr ⟩
```
where `φ ∈ End_K(V)`, `hbij` is a proof that `φ` is bijective (i.e. `φ ∈ GL(V)`),
and `hirr` is a proof that `charpoly(φ)` is irreducible in `K[X]`.

**Definition 2.3 (Certificate density).** For a finite group `G` and a decidable
predicate `C : G → Prop`, the *certificate density* is the rational number
```
certificateDensity(C)  =  #{ g ∈ G : C(g) }  /  #G  ∈  ℚ.
```

**Definition 2.4 (Generation certificate system).** A *generation certificate
system* on a group `G` is a predicate `Cert : G → Prop` together with the
guarantee
```
∀ g, Cert(g) → ∀ H ≤ G,  g ∈ H →  H = G  ∨  [G : H] ≤ 2,
```
i.e. any subgroup `H` containing a certified element is the whole group or has
index at most `2`. The index-`2` slack accommodates the symmetric-group case,
where certified elements generate at least the alternating subgroup `A_n`.

---

## 3. Preliminary lemmas on restriction

The proof of the main theorem transfers polynomial identities from `φ` to its
restriction `φ|_W` on an invariant subspace `W`. We record the lemmas; in each,
`φ.restrict hW : W → W` denotes the restricted endomorphism and
`W.subtype : W → V` the inclusion.

**Lemma 3.1 (Intertwining).** For invariant `W`,
```
W.subtype ∘ (φ|_W)  =  φ ∘ W.subtype.
```
*Proof.* On an element `⟨x, hx⟩ ∈ W`, both sides equal `φ(x)`, by the definition
of the restricted map. ∎

**Lemma 3.2 (Annihilation descends to restrictions).** Let `p ∈ K[X]`. If
`p(φ) = 0` (the zero endomorphism of `V`), then `p(φ|_W) = 0` for every invariant
`W`.

*Proof sketch.* Write `p(φ) = Σ_i c_i φ^i`. By induction on `i` using the
intertwining Lemma 3.1, `(φ|_W)^i` agrees with `φ^i` after composing with the
inclusion: `W.subtype ∘ (φ|_W)^i = φ^i ∘ W.subtype`. Summing with coefficients,
`W.subtype ∘ p(φ|_W) = p(φ) ∘ W.subtype = 0`. Since `W.subtype` is injective,
`p(φ|_W) = 0`. ∎

**Lemma 3.3 (Minimal polynomial divides).** For invariant `W`,
```
minpoly_K(φ|_W)  ∣  minpoly_K(φ).
```
*Proof.* By Lemma 3.2 applied to `p = minpoly_K(φ)` (which annihilates `φ` by
definition), `minpoly_K(φ)` annihilates `φ|_W`. The minimal polynomial of `φ|_W`
divides every annihilating polynomial, whence the claim. ∎

**Lemma 3.4 (Minimal equals characteristic under irreducibility).** If
`charpoly(φ)` is irreducible, then
```
minpoly_K(φ)  =  charpoly(φ).
```
*Proof sketch.* For nontrivial `V`: by Cayley–Hamilton, `charpoly(φ)` is a monic
annihilating polynomial of `φ`. The minimal polynomial divides it; since
`charpoly(φ)` is irreducible and `minpoly_K(φ)` is monic and non-unit, they are
associate, hence equal (both monic). For the degenerate case `V = 0`, `φ = 0` and
`charpoly(φ) = 1`, which is a unit, contradicting irreducibility unless the case
is vacuous; the formalization dispatches the zero-dimensional and
one-dimensional edge cases by direct computation on the degree of `charpoly`. ∎

---

## 4. The Irreducible Action Theorem

**Theorem 4.1 (Irreducible Action Theorem;
`eq_bot_or_top_of_charpoly_irreducible`).** Let `V` be finite-dimensional over
`K` and let `φ ∈ End_K(V)` have irreducible characteristic polynomial. Then for
every invariant submodule `W`,
```
W = ⊥   or   W = ⊤.
```

*Proof.* If `W = ⊥` we are done, so assume `W ≠ ⊥`; we show `W = ⊤`.

*Step 1 — the restricted minimal polynomial is non-trivial.* Since `W ≠ ⊥`,
there is a nonzero `x ∈ W`. The restricted map `φ|_W` is a genuine endomorphism
of the nonzero space `W`, so its minimal polynomial is not the unit `1` (a unit
minimal polynomial would force `1·(\mathrm{id}) = 0` on `W`, impossible for
`W ≠ 0`).

*Step 2 — it equals the characteristic polynomial of `φ`.* By Lemma 3.3,
`minpoly_K(φ|_W) ∣ minpoly_K(φ)`, and `minpoly_K(φ) ∣ charpoly(φ)` always. Hence
`minpoly_K(φ|_W) ∣ charpoly(φ)`. Because `charpoly(φ)` is irreducible, its only
monic divisors are `1` and itself; by Step 1 the divisor is not `1`, so
```
minpoly_K(φ|_W) = charpoly(φ).
```

*Step 3 — dimension count.* The degree of the minimal polynomial of any
endomorphism is at most the dimension of the space it acts on:
`deg minpoly_K(φ|_W) ≤ dim_K(W)`. The degree of `charpoly(φ)` equals `dim_K(V)`.
Combining with Step 2,
```
dim_K(V) = deg charpoly(φ) = deg minpoly_K(φ|_W) ≤ dim_K(W) ≤ dim_K(V).
```
All inequalities are equalities, so `dim_K(W) = dim_K(V)`. A subspace of full
dimension equals the whole space: `W = ⊤`. ∎

**Remark 4.2.** The theorem is the exact statement that `V` is a *simple*
`K[X]`-module under the action `X ↦ φ`, equivalently that the linear action of
`φ` (and of the cyclic group it generates) is *irreducible*. The hypothesis is
purely algebraic and decidable, while the conclusion is a representation-theoretic
irreducibility — this is the crux of the certificate philosophy.

---

## 5. Cross-domain consequences

### 5.1 Coding theory: orbit spanning

**Lemma 5.0 (Orbit span is invariant; `span_orbit_invariant`).** For any
`φ ∈ End_K(V)` and any `v ∈ V`, the submodule
```
O(v) := span_K { φ^m(v) : m ∈ ℕ }
```
is invariant under `φ`.

*Proof.* `φ` sends the spanning generator `φ^m(v)` to `φ^{m+1}(v)`, another
generator; invariance extends to the span by linearity. ∎

**Theorem 5.1 (Orbit Spanning Theorem;
`span_orbit_eq_top_of_irreducible`).** If `charpoly(φ)` is irreducible and
`v ≠ 0`, then
```
span_K { φ^m(v) : m ∈ ℕ } = ⊤.
```

*Proof.* By Lemma 5.0 the orbit span `O(v)` is invariant; by Theorem 4.1 it is
`⊥` or `⊤`. It contains `v ≠ 0`, hence is not `⊥`, hence is `⊤`. ∎

**Application.** A linear feedback shift register (LFSR) of length `n` over `𝔽_q`
evolves its state by a fixed endomorphism whose characteristic polynomial is the
feedback polynomial. Theorem 5.1 says that when the feedback polynomial is
irreducible, the state orbit of any nonzero seed is full-dimensional; with the
stronger condition that it be *primitive* (the companion matrix has multiplicative
order `q^n − 1`), the orbit visits all `q^n − 1` nonzero states, the maximal
period. The same mechanism — a single generator polynomial sweeping out a space
by repeated shifts — is the algebraic engine of cyclic codes.

### 5.2 Finite geometry: no fixed proper flat

**Theorem 5.2 (No Fixed Proper Flat;
`irreducible_endomorphism_has_no_fixed_proper_projective_subspace`).** If
`charpoly(φ)` is irreducible, there is no submodule `W` with
```
W ≠ ⊥,  W ≠ ⊤,  and  W invariant under φ.
```

*Proof.* Immediate from Theorem 4.1: such a `W` would be neither `⊥` nor `⊤`,
contradicting the dichotomy. ∎

**Application.** In the projective space `PG(n−1, q)` an invertible `φ` acts as a
collineation, and invariant subspaces correspond to invariant projective flats.
Theorem 5.2 states that an irreducible `φ` fixes no proper flat — the defining
geometric property of a **Singer cycle**, which permutes the `(q^n − 1)/(q − 1)`
projective points in a single cycle. The theorem isolates the linear-algebra
reason for that maximal transitivity.

### 5.3 Specialization to prime fields

**Theorem 5.3 (Prime-field Singer certificate;
`singerCycle_has_no_nontrivial_invariant_subspace`).** For a prime `p`, a
finite-dimensional `𝔽_p`-space `V`, and `φ ∈ End_{𝔽_p}(V)` with irreducible
`charpoly(φ)`, every invariant submodule is `⊥` or `⊤`.

*Proof.* A direct instance of Theorem 4.1 with `K = 𝔽_p = ℤ/pℤ`. ∎

This is the case of greatest practical importance in computational group theory,
where `GL_n(𝔽_p)` and its subgroups are the central objects.

---

## 6. Quantitative foundation: density positivity

**Theorem 6.1 (Generation Lower Bound;
`generation_lower_bound_of_certificate_system`).** Let `G` be a finite group and
`C : G → Prop` a decidable predicate with at least one certified element. Then
```
0 < certificateDensity(C).
```

*Proof.* The hypothesis provides `g₀` with `C(g₀)`, so the certified subtype
`{ g : C(g) }` is nonempty and has positive cardinality; `#G > 0` since `G`
contains the identity. The quotient of two positive naturals, cast to `ℚ`, is
positive. ∎

**Discussion.** Theorem 6.1 is the base of a quantitative ladder. The classical
content needed for *high-probability* generation is the much sharper estimate
that the density of irreducible-characteristic-polynomial elements in
`GL_n(𝔽_q)` is bounded below by an explicit `c_q / n`. Our framework is designed
to consume exactly such a density bound: combined with a certificate system
(Definition 2.4) it yields, by standard inclusion–exclusion over maximal
subgroups, a generation probability of the form `1 − O(q^{-1})`. We record the
two missing quantitative inputs as Conjectures A and B in Section 9.

---

## 7. The abstract certificate interface

The structural skeleton common to Dixon's symmetric-group theorem and the
Neumann–Praeger linear theorem is captured by Definition 2.4. From its single
hypothesis one obtains, uniformly:

- **Density positivity** (Theorem 6.1), given one certified element.
- **Subgroup dichotomy**: any subgroup meeting the certified set is `G` or of
  index `≤ 2`.

Instantiations:

| Case | Group `G` | `Cert(g)` | Source |
|---|---|---|---|
| Symmetric | `S_n` | `g` is an `n`-cycle / fixed-point-free of prime order | Dixon (1969) |
| Linear | `GL_n(𝔽_q)` | `charpoly(g)` irreducible (Singer certificate) | this work / Neumann–Praeger (1992) |

The value of the abstraction is that the *generation logic* — positive density of
a checkable certificate plus the dichotomy — is proved once and reused, while the
domain-specific work reduces to (a) verifying the certificate is cheap and (b)
bounding its density.

---

## 8. Algorithms

We summarize the computational procedures the certificate framework relies on;
full type-hinted implementations accompany this paper.

**Algorithm A — Certificate verification.** Given a matrix `M ∈ GL_n(𝔽_q)`:
1. Compute `charpoly(M)` (e.g. by the Faddeev–LeVerrier recursion or fraction-free
   Gaussian elimination on `XI − M`), cost `O(n^3)` field operations.
2. Test irreducibility of `charpoly(M)` over `𝔽_q` (Rabin's test: gcd with
   `X^{q^d} − X` for proper divisors `d` of `n`), cost polynomial in `n log q`.
3. Output the certificate iff both `det(M) ≠ 0` and `charpoly(M)` irreducible.

**Algorithm B — Certificate density estimation.** Estimate
`certificateDensity` by Monte Carlo: sample `N` uniform invertible matrices, run
Algorithm A on each, and return the empirical fraction certified. By Hoeffding,
`O(ε^{-2} log δ^{-1})` samples give an `ε`-accurate estimate with confidence
`1 − δ`. For small `n, q` the exact density is obtained by exhaustive enumeration.

**Algorithm C — Invariant-subspace witness search (falsification harness).**
Given `M`, enumerate (or randomly sample) proper nonzero subspaces `W` and test
invariance `M·W ⊆ W`. Theorem 4.1 predicts: if `charpoly(M)` is irreducible the
search returns *no* witness; if reducible, witnesses exist. This is the empirical
counterpart of the structural theorem and a useful unit test.

---

## 9. Conjectures and future work

**Conjecture A (Linear certificate density lower bound).** For fixed prime power
`q` there is `c_q > 0` such that for all `n`,
```
#{ M ∈ GL_n(𝔽_q) : charpoly(M) irreducible } / #GL_n(𝔽_q)  ≥  c_q / n.
```
This is the linear analogue of the proportion of `n`-cycles in `S_n` and is the
key input upgrading Theorem 6.1 to an asymptotically sharp bound. (The exact
count of irreducible monic polynomials of degree `n` over `𝔽_q` is
`(1/n) Σ_{d ∣ n} μ(d) q^{n/d}`, and each corresponds to a conjugacy class of
companion matrices; the density estimate follows from controlling centralizer
sizes.)

**Conjecture B (Certificate sufficiency for high-probability generation).** For
random `g, h ∈ GL_n(𝔽_q)`, if `charpoly(g)` is irreducible and `det(h)` generates
`𝔽_q^×`, then
```
Pr[ ⟨g, h⟩ = GL_n(𝔽_q) ]  ≥  1 − O(q^{-1}).
```

**Further directions.**
- Extend the certificate to *primitivity* of `charpoly` to obtain maximal-order
  Singer cycles and full LFSR period results.
- Formalize the density count of Conjecture A via Möbius inversion over monic
  irreducibles, then discharge Theorem 6.1's quantitative upgrade.
- Generalize the abstract interface to classical groups (`Sp`, `SU`, `Ω`) where
  Neumann–Praeger-style bounds hold, identifying the appropriate certificate
  (e.g. `ppd`-elements: primitive prime divisor elements).
- Connect the orbit-spanning theorem to a formal account of cyclic codes and
  BCH bounds.

---

## 10. Conclusion

A single decidable algebraic predicate — irreducibility of the characteristic
polynomial — propagates into a representation-theoretic irreducibility (no
invariant subspaces), and from there into orbit spanning, fixed-flat-freeness,
and a generation certificate, all unified under one abstract interface and
underwritten by a strictly positive density. The structural backbone is complete
and verified; what remains is quantitative, and we have isolated it as two
precise conjectures. The framework demonstrates how a cheap, checkable
certificate can stand in for an expensive structural property, the organizing
principle behind the randomized algorithms that make modern computational group
theory possible.

---

## References

- Dixon, J. D. (1969). *The probability of generating the symmetric group.*
  Mathematische Zeitschrift, 110, 199–205.
- Huppert, B. (1967). *Endliche Gruppen I.* Springer.
- Neumann, P. M., & Praeger, C. E. (1992). *A recognition algorithm for special
  linear groups.* Proc. London Math. Soc. (3) 65, 555–603.
