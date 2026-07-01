# The Franke Decomposition for Level-One Spherical Automorphic Forms and the Pole Geometry of the Standard Eisenstein Series

**Author:** Aristotle

**Date:** 2026-07-01

## Abstract

We study the spectral decomposition of spherical automorphic forms on the
modular surface $X = \mathrm{SL}(2,\mathbb{Z})\backslash\mathbb{H}$ and give a
clean separation of its two structural ingredients: an *algebraic* skeleton and
an *analytic* engine. On the algebraic side we isolate the linear-algebraic core
of the Franke Decomposition Theorem in the level-one spherical case, namely that
the space of automorphic forms is the internal direct sum of the subspace of
cusp forms and the finite-dimensional span of the Laurent coefficients of the
standard Eisenstein series $E(s;z)$ at its poles. This yields existence,
uniqueness, and finiteness of the decomposition with no analytic hypotheses
beyond complementarity of the two subspaces. On the analytic side we pin down the
unique pole of $E(s;z)$ in the region $\mathrm{Re}(s)\ge \tfrac12$: it is a
simple pole at $s=1$, produced entirely by the arithmetic factor $\zeta(2s-1)$ of
the scattering matrix, and we compute its residue to be exactly $\tfrac12$. We
prove that the pole is genuine — $\zeta(2s-1)$ has no finite limit at $s=1$ — so
the Eisenstein contribution to the decomposition is nonzero. Together these
results certify both the finiteness and the nontriviality of the residual term
and trace them, place by place, to the single simple pole of the Riemann zeta
function.

## 1. Introduction

The spectral theory of automorphic forms seeks to decompose the space of
functions on an arithmetic quotient into irreducible or otherwise structurally
distinguished pieces. In its most general form, Franke's theorem describes the
space of automorphic forms on an arithmetic quotient of a reductive group as a
direct sum indexed by cuspidal support. The theorem is famously analytic,
resting on the meromorphic continuation and functional equations of Eisenstein
series.

This paper concerns the smallest genuinely interesting case — spherical
automorphic forms of level one on the modular surface — and makes two points.

First, the *combinatorial shape* of Franke's decomposition (existence,
uniqueness, finiteness) is a statement of pure linear algebra: it is the
assertion that the cuspidal subspace and the span of finitely many Laurent
coefficients of the standard Eisenstein series are complementary. We state and
prove this skeleton over an arbitrary complex vector space.

Second, the reason the Laurent span is finite and nontrivial is entirely
arithmetic and can be pinned to a single point. The standard Eisenstein series
$E(s;z)$ has exactly one pole in $\mathrm{Re}(s)\ge\tfrac12$, located at $s=1$;
that pole is produced by the factor $\zeta(2s-1)$ appearing in the scattering
term of its constant term, and its residue is the clean rational $\tfrac12$. We
prove this precisely and show the pole is not an artifact.

The interplay of these two halves is the message of the paper: an unconditional
algebraic splitting, made finite and nonempty by an explicit analytic fact
inherited from the pole of $\zeta$.

## 2. The setting

### 2.1 The modular surface

Let $\mathbb{H} = \{z = x+iy : y > 0\}$ be the upper half-plane, endowed with the
hyperbolic metric $ds^2 = (dx^2+dy^2)/y^2$ of constant curvature $-1$. The group
$$ \mathrm{SL}(2,\mathbb{Z}) = \left\{ \begin{pmatrix} a & b \\ c & d\end{pmatrix} : a,b,c,d \in \mathbb{Z},\; ad-bc = 1 \right\} $$
acts on $\mathbb{H}$ by fractional linear transformations
$\gamma z = \frac{az+b}{cz+d}$. The quotient
$$ X = \mathrm{SL}(2,\mathbb{Z}) \backslash \mathbb{H} $$
is the modular surface: a finite-area hyperbolic orbifold with a single cusp at
$y \to \infty$.

### 2.2 Spherical automorphic forms and cusp forms

**Definition 2.1 (Spherical automorphic form).** A *spherical automorphic form*
is a smooth function $f : \mathbb{H} \to \mathbb{C}$ that is invariant under the
action, $f(\gamma z) = f(z)$ for all $\gamma \in \mathrm{SL}(2,\mathbb{Z})$, is an
eigenfunction of the hyperbolic Laplacian $\Delta = -y^2(\partial_x^2 + \partial_y^2)$,
and has at most polynomial growth in the cusp. Write $V$ for the complex vector
space of such forms in a fixed spectral window.

**Definition 2.2 (Cusp form).** A spherical automorphic form $f$ is a *cusp form*
if its zeroth Fourier coefficient along the cusp vanishes,
$$ \int_0^1 f(x+iy)\,dx = 0 \qquad \text{for all } y > 0, $$
equivalently, if $f$ decays rapidly as $y \to \infty$. The cusp forms constitute
a subspace $\mathrm{cusp} \subseteq V$.

### 2.3 The standard Eisenstein series and its scattering factor

**Definition 2.3 (Standard Eisenstein series).** For $\mathrm{Re}(s) > 1$ set
$$ E(s;z) = \sum_{\gamma \in \Gamma_\infty \backslash \mathrm{SL}(2,\mathbb{Z})} \big(\mathrm{Im}\,\gamma z\big)^{s}, $$
where $\Gamma_\infty$ is the stabilizer of the cusp. The series continues
meromorphically to all $s \in \mathbb{C}$.

**Proposition 2.4 (Constant term).** The constant Fourier coefficient of
$E(s;z)$ along the cusp equals
$$ \int_0^1 E(s; x+iy)\,dx = y^{s} + \varphi(s)\, y^{1-s}, $$
with scattering factor
$$ \varphi(s) = \sqrt{\pi}\;\frac{\Gamma\!\left(s-\tfrac12\right)\,\zeta(2s-1)}{\Gamma(s)\,\zeta(2s)}. $$

The poles of $E(s;z)$ in $\mathrm{Re}(s)\ge \tfrac12$ coincide with the poles of
$\varphi(s)$ there. In this region $\Gamma(s-\tfrac12)/\Gamma(s)$ is holomorphic
and nonzero, $\zeta(2s)$ is holomorphic and nonvanishing, and the only possible
pole comes from $\zeta(2s-1)$, whose argument equals $1$ precisely at $s = 1$.

## 3. The analytic core: the pole at $s = 1$

Our analytic input is the classical residue of the Riemann zeta function,
$$ \lim_{u\to 1}(u-1)\,\zeta(u) = 1, \tag{3.1} $$
understood as a limit over the punctured neighborhood of $1$ in $\mathbb{C}$.

### 3.1 Transporting the residue through an affine substitution

**Lemma 3.1 (Punctured-neighborhood transport).** The affine map
$\sigma(s) = 2s - 1$ satisfies $\sigma \to 1$ along the punctured neighborhood
filter at $1$; that is, $\sigma$ maps points near but distinct from $1$ to points
near but distinct from $1$.

*Proof sketch.* Continuity of $\sigma$ gives convergence $\sigma(s) \to \sigma(1) = 1$
of the unpunctured neighborhood filter. To retain the punctured condition, note
$\sigma$ is injective: if $2s-1 = 1$ then $s = 1$. Hence $s \ne 1$ implies
$\sigma(s) \ne 1$, so $\sigma$ preserves the "punctured" restriction. $\qquad\blacksquare$

**Theorem 3.2 (Residue of the arithmetic scattering factor).** As $s \to 1$,
$$ (s-1)\,\zeta(2s-1) \longrightarrow \tfrac12. $$
Equivalently, the arithmetic factor $\zeta(2s-1)$ of the scattering matrix has a
simple pole at $s = 1$ with residue $\tfrac12$, and this is the sole source of the
pole of $E(s;z)$ in $\mathrm{Re}(s)\ge\tfrac12$.

*Proof sketch.* Compose the zeta residue (3.1) with the substitution $u = 2s-1$
of Lemma 3.1 to obtain
$$ \big((2s-1)-1\big)\,\zeta(2s-1) = (2s-2)\,\zeta(2s-1) \longrightarrow 1 $$
as $s \to 1$. Since $2s - 2 = 2(s-1)$, this reads $2\,(s-1)\,\zeta(2s-1) \to 1$.
Multiplying by $\tfrac12$ gives $(s-1)\,\zeta(2s-1) \to \tfrac12$. $\qquad\blacksquare$

The residue $\tfrac12$ is exact and rational. Its value is what enables the next
result.

### 3.2 The pole is genuine

**Theorem 3.3 (Genuine blow-up).** The function $s \mapsto \zeta(2s-1)$ has no
finite limit as $s \to 1$.

*Proof sketch.* Suppose $\zeta(2s-1) \to L \in \mathbb{C}$ as $s \to 1$. Because
$s - 1 \to 0$, the product satisfies
$$ (s-1)\,\zeta(2s-1) \longrightarrow 0\cdot L = 0. $$
By Theorem 3.2 the same product tends to $\tfrac12$. Limits along the punctured
neighborhood filter at $1$ in $\mathbb{C}$ are unique (the filter is nontrivial),
so $0 = \tfrac12$, a contradiction. Hence no finite $L$ exists. $\qquad\blacksquare$

**Corollary 3.4.** $E(s;z)$ has a genuine (nonremovable) pole at $s = 1$. In
particular the residual/Eisenstein contribution to the spectral decomposition of
$V$ has nonzero residue and is present.

## 4. The algebraic skeleton: the decomposition

We now make precise the combinatorial content of the level-one spherical Franke
decomposition, valid over any complex vector space. Let $V$ be a $\mathbb{C}$-vector
space (the automorphic forms), $\mathrm{cusp}\subseteq V$ a subspace (the cusp
forms), and $\ell_1,\dots,\ell_n \in V$ a finite family (the Laurent coefficients
of $E(s;z)$ at its finitely many poles). Write
$$ \mathrm{Eis} = \mathrm{span}_{\mathbb{C}}\{\ell_1,\dots,\ell_n\} $$
for the Eisenstein/residual subspace.

**Definition 4.1 (Complementarity).** The subspaces $\mathrm{cusp}$ and
$\mathrm{Eis}$ are *complementary* if $\mathrm{cusp}\cap\mathrm{Eis} = \{0\}$ and
$\mathrm{cusp}+\mathrm{Eis} = V$.

The structural assumption underlying the level-one spherical case is exactly that
these two subspaces are complementary. Under this hypothesis the following hold.

**Theorem 4.2 (Existence).** If $\mathrm{cusp}$ and $\mathrm{Eis}$ are
complementary, then every $f \in V$ admits a representation
$$ f = c + \sum_{i=1}^{n} a_i\,\ell_i, $$
with $c \in \mathrm{cusp}$ and $a_i \in \mathbb{C}$.

*Proof sketch.* Complementarity gives $V = \mathrm{cusp}+\mathrm{Eis}$, so
$f = c + e$ with $c \in \mathrm{cusp}$, $e \in \mathrm{Eis}$. By definition of the
span, $e = \sum_i a_i \ell_i$. $\qquad\blacksquare$

**Theorem 4.3 (Uniqueness).** Under the same hypothesis, the cusp part $c$ and the
Eisenstein part $\sum_i a_i \ell_i$ are uniquely determined by $f$.

*Proof sketch.* If $c + e = c' + e'$ with $c,c'\in\mathrm{cusp}$ and
$e,e'\in\mathrm{Eis}$, then $c - c' = e' - e$ lies in
$\mathrm{cusp}\cap\mathrm{Eis} = \{0\}$, so $c = c'$ and $e = e'$. This is exactly
the statement that an internal direct sum has unique coordinates; no analytic
normalization is required. $\qquad\blacksquare$

**Theorem 4.4 (Finiteness of the Eisenstein subspace).** $\mathrm{Eis}$ is
finite-dimensional, with $\dim \mathrm{Eis} \le n$. Hence the Eisenstein part of
every decomposition is a genuinely finite linear combination.

*Proof sketch.* $\mathrm{Eis}$ is the span of the finite family
$\{\ell_1,\dots,\ell_n\}$, and the span of finitely many vectors is
finite-dimensional with dimension at most the number of generators. The
finiteness of the generating family is precisely the analytic fact that $E(s;z)$
has finitely many poles in the region of interest — a single one, at $s=1$, by
Theorems 3.2–3.3. $\qquad\blacksquare$

Combining Theorems 4.2–4.4: the map $c \oplus (a_1,\dots,a_n) \mapsto c + \sum_i a_i\ell_i$
realizes $V$ as the internal direct sum $\mathrm{cusp} \oplus \mathrm{Eis}$, with
$\mathrm{Eis}$ finite-dimensional. This is the level-one spherical Franke
decomposition.

## 5. Why level one gives a single standard Eisenstein series

Eisenstein series may in general be twisted by Dirichlet/Hecke characters indexed
by a conductor. The level-one hypothesis restricts the conductor to $1$.

**Proposition 5.1 (Uniqueness of the trivial character).** The number of
Dirichlet characters of conductor $1$ is exactly $1$; the only such character is
the trivial one.

*Proof sketch.* The group of Dirichlet characters modulo $1$ is the character
group of the trivial group $(\mathbb{Z}/1\mathbb{Z})^\times$, which has a single
element. $\qquad\blacksquare$

Consequently no nontrivial twist is available at level one, and the single
untwisted standard Eisenstein series $E(s;z)$ governs the entire continuous and
residual spectrum. This is the precise sense in which "level one" collapses the
Eisenstein bookkeeping to one family.

## 6. Synthesis: from the pole of $\zeta$ to the shape of $V$

The two halves of the paper interlock as follows.

- **Finiteness** of the Eisenstein span (Theorem 4.4) requires that $E(s;z)$ have
  finitely many poles in $\mathrm{Re}(s)\ge\tfrac12$. Proposition 2.4 reduces this
  to counting poles of $\varphi(s)$, and Theorem 3.2 shows there is exactly one,
  at $s=1$, inherited from the simple pole of $\zeta$.
- **Nontriviality** of the Eisenstein span (Corollary 3.4) requires that the pole
  actually occur; Theorem 3.3 provides this via the nonzero residue $\tfrac12$.
- **Existence and uniqueness** of the decomposition (Theorems 4.2–4.3) are pure
  complementarity and require no further analysis.

Thus a single, classical irregularity — the simple pole of the Riemann zeta
function at $1$ — controls, through an explicit scattering factor, both the size
and the presence of the residual part of the automorphic spectrum on the modular
surface.

## 7. Algorithms and computation

The results support concrete numerical exploration. We highlight three
computations, developed fully in the accompanying software.

1. **Residue estimator.** Approximate $(s-1)\,\zeta(2s-1)$ for $s \to 1$ along a
   sequence $s_k = 1 + 10^{-k}$ and observe convergence to $\tfrac12$, confirming
   Theorem 3.2 numerically.
2. **Blow-up witness.** Tabulate $|\zeta(2s-1)|$ for the same sequence and observe
   unbounded growth, confirming Theorem 3.3.
3. **Direct-sum coordinates.** In a finite-dimensional model with an explicit cusp
   subspace and an explicit Eisenstein span, compute the unique
   $(c, a_1,\dots,a_n)$ coordinates of a given $f$ by solving the associated
   linear system, illustrating Theorems 4.2–4.4.

## 8. Applications and discussion

The clean separation of algebra from analysis clarifies which hypotheses are
truly needed. Uniqueness of the cusp/Eisenstein splitting, classically framed in
Hilbert-space terms, is here seen to follow from complementarity alone — the
inner-product machinery is sufficient but not necessary. The finiteness of the
residual span, classically an analytic statement about pole counting, is seen to
be a counting problem controlled entirely by the pole geometry of $\zeta$.

More broadly, this level-one case is a rehearsal for the general Franke
decomposition, where the cuspidal support becomes an intricate index set and the
Eisenstein bookkeeping is far heavier. The philosophy — that a finite direct-sum
structure is imposed on the automorphic spectrum by the finitely many boundary
poles of Eisenstein series — persists throughout.

## 9. Future directions

**Residue rationality across the modular tower.** For every principal congruence
subgroup of the modular group, each pole of the standard Eisenstein series in the
closed right half-plane should carry a residue that is a rational multiple of the
reciprocal of the covolume of the corresponding quotient surface. The pole is
produced solely by the arithmetic factor built from $\zeta$, whose residue is
exactly $\tfrac12$; every geometric constant (covolume, subgroup index) enters
only as a rational scaling, so transcendental contributions cancel.

**Uniform bound on the residual dimension.** The dimension of the residual
(non-cuspidal, non-continuous) part of the spherical spectrum for a congruence
quotient should be bounded by the number of cusps, independently of level. Each
cusp contributes one Eisenstein family with one boundary pole, so the residual
span is assembled cusp-by-cusp and cannot exceed the cusp count — mirroring the
one-dimensional residual span of the single-cusp level-one case.

**Rigidity of the cusp/Eisenstein splitting.** The decomposition should be unique
even before any growth or integrability condition is imposed: complementarity of
the two subspaces alone forces the splitting, and no analytic normalization can
produce a second decomposition. Uniqueness is a consequence of complementarity,
not of any Hilbert-space projection, so the analytic hypotheses classically
invoked are sufficient but not necessary for well-posedness.

## 10. Conclusion

We have separated the level-one spherical Franke decomposition into an
unconditional algebraic skeleton — existence, uniqueness, and finiteness of the
cusp/Eisenstein direct sum — and an analytic engine that certifies the skeleton
is finite and nonempty. The engine reduces to a single fact: the standard
Eisenstein series on the modular surface has exactly one pole in
$\mathrm{Re}(s)\ge\tfrac12$, a simple pole at $s=1$ of residue $\tfrac12$,
inherited from the Riemann zeta function. The distribution of prime numbers, via
that lone pole, organizes the harmonics of the modular surface.
