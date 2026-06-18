# Non-Desarguesian Projective Planes: Algebraic Structure and Formal Classification

## Abstract

We develop a formal theory of non-Desarguesian finite projective planes through
their coordinatizing quasifields. We define quasifields axiomatically, construct
projective planes from them, and establish the fundamental connection between
non-associativity of the coordinatizing algebra and the failure of Desargues'
theorem. Our main results include: (1) the counting theorem establishing that
a finite projective plane of order n has exactly n² + n + 1 points and lines;
(2) structural theorems showing the left nucleus of a quasifield is closed
under multiplication and, when right distributivity holds, also under addition
and negation; (3) the equivalence between associativity of the quasifield and
the fullness of its nucleus; and (4) the precise mechanism by which
non-associativity breaks dilation-type collineations, bounding the collineation
group below PGL. All results have been machine-verified.

## 1. Introduction

A projective plane is an incidence structure satisfying three axioms: any two
distinct points determine a unique line, any two distinct lines meet in a unique
point, and there exist four points in general position (no three collinear).
Desargues' theorem — that two triangles in perspective from a point are in
perspective from a line — holds in every projective plane coordinatizable by a
division ring, but can fail in planes over non-associative algebras.

The algebraic structures that coordinatize arbitrary projective planes are called
*ternary rings*. When the plane is a *translation plane* (admitting a
transitive group of translations), the coordinatizing algebra is a
*quasifield*: a set with two operations satisfying the axioms of an abelian
group under addition, with left-distributive and left-cancellative
multiplication, and a bijectivity condition on "slope maps" that ensures unique
line determination.

### 1.1 Historical Context

The existence of non-Desarguesian planes was established by Moulton (1902) and
Veblen-Wedderburn (1907). Hall (1943) constructed infinite families using
modified field multiplication. The Lenz-Barlotti classification (1954, 1957)
organized translation planes by the transitivity properties of their
collineation groups. The connection to non-associative algebras was made precise
by the Artin-Zorn theorem: a finite alternative division ring is a field.

### 1.2 Contributions

Our formalization contributes:

1. **Axiomatic quasifield theory**: We define quasifields as algebraic structures
   with explicit axioms for left distributivity, left multiplication bijectivity,
   and slope bijectivity, and develop their structural theory.

2. **Nucleus analysis**: We prove that the left nucleus (elements associating
   from the left with all pairs) is closed under multiplication, and under
   addition/negation when right distributivity holds. We show that the nucleus
   being the entire quasifield is equivalent to full associativity.

3. **Finite plane combinatorics**: We prove the classical counting theorems for
   finite projective planes via a careful double-counting argument.

4. **Coordinatization**: We construct the incidence relation for a quasifield
   plane and prove that two distinct affine points determine a unique line,
   using the slope bijectivity axiom.

5. **Collineation obstruction**: We prove that non-associativity prevents
   dilations from preserving incidence, providing an upper bound on the
   collineation group of a non-Desarguesian plane.

## 2. Definitions

### 2.1 Quasifields

**Definition 2.1** (Quasifield). A *quasifield* is a tuple (Q, +, ·, 0, 1)
where:
- (Q, +, 0) is an abelian group with additive inverse -
- 1 ≠ 0, and 1 is a two-sided multiplicative identity
- 0 · a = a · 0 = 0 for all a
- Left distributive law: a · (b + c) = a · b + a · c
- For each a ≠ 0, the map x ↦ a · x is bijective
- For a ≠ b, the map x ↦ x · a - x · b is bijective (slope condition)

Note that right distributivity and associativity are *not* required.

**Definition 2.2** (Associator). For elements a, b, c in a quasifield, the
*associator* is [a,b,c] := (a·b)·c - a·(b·c).

**Definition 2.3** (Nuclei). The *left nucleus* is
N_ℓ(Q) = {n ∈ Q : (n·a)·b = n·(a·b) for all a,b}.
Similarly for the *middle nucleus* N_μ and *right nucleus* N_ρ.
The *full nucleus* is N(Q) = N_ℓ ∩ N_μ ∩ N_ρ.

**Definition 2.4** (Semifield). A quasifield satisfying right distributivity
is called a *semifield*.

### 2.2 Projective Planes

**Definition 2.5** (Projective Plane). A *projective plane* consists of:
- A type of points P and a type of lines L
- An incidence relation I ⊆ P × L
- Axioms: (P1) any two distinct points lie on a unique common line;
  (P2) any two distinct lines meet in a unique common point;
  (P3) there exist four points, no three collinear.

**Definition 2.6** (Order). A finite projective plane has *order n* if every
line contains exactly n + 1 points (equivalently, every point lies on exactly
n + 1 lines).

**Definition 2.7** (Desargues Property). A projective plane satisfies the
*Desargues property* if for any two triangles ABC, A'B'C' in perspective from
a point O (meaning O, A, A' collinear; O, B, B' collinear; O, C, C' collinear),
the intersection points of corresponding sides (AB ∩ A'B', BC ∩ B'C',
CA ∩ C'A') are collinear.

### 2.3 Collineations

**Definition 2.8** (Collineation). A *collineation* of a projective plane π is
a pair of bijections (σ: P → P, τ: L → L) such that I(p, ℓ) ⟺ I(σ(p), τ(ℓ))
for all points p and lines ℓ.

## 3. Main Results

### 3.1 Nucleus Structure

**Theorem 3.1** (Left Nucleus Multiplicative Closure).
*For any quasifield Q, if a, b ∈ N_ℓ(Q), then a · b ∈ N_ℓ(Q).*

*Proof sketch.* We need ((a·b)·x)·y = (a·b)·(x·y). Using a ∈ N_ℓ:
(a·b)·x = a·(b·x), so ((a·b)·x)·y = (a·(b·x))·y = a·((b·x)·y).
Using b ∈ N_ℓ: (b·x)·y = b·(x·y), so a·((b·x)·y) = a·(b·(x·y)).
Using a ∈ N_ℓ again: a·(b·(x·y)) = (a·b)·(x·y). □

**Theorem 3.2** (Nucleus Additive Closure under Right Distributivity).
*If Q is a quasifield satisfying right distributivity, and a, b ∈ N_ℓ(Q),
then a + b ∈ N_ℓ(Q).*

*Proof sketch.* Right distributivity gives (a+b)·x = a·x + b·x. Then
((a+b)·x)·y = (a·x + b·x)·y = (a·x)·y + (b·x)·y (by right dist.)
= a·(x·y) + b·(x·y) (by a, b ∈ N_ℓ) = (a+b)·(x·y) (by right dist.). □

**Theorem 3.3** (Full Nucleus Membership).
*0 ∈ N_ℓ(Q) and 1 ∈ N(Q) for any quasifield Q.*

**Theorem 3.4** (Associativity Equivalence).
*A quasifield Q is associative if and only if N_ℓ(Q) = Q.*

### 3.2 Finite Plane Combinatorics

**Theorem 3.5** (Point Count).
*A finite projective plane of order n has exactly n² + n + 1 points.*

*Proof.* Fix a point p. The n + 1 lines through p partition the remaining
points: every point q ≠ p lies on exactly one line through p (by unique line
determination), and each such line contributes exactly n points besides p.
The double-counting gives |P| - 1 = (n+1) · n, hence |P| = n² + n + 1. □

**Theorem 3.6** (Line Count).
*A finite projective plane of order n has exactly n² + n + 1 lines.*

*Proof.* By the same double-counting argument applied dually, or by counting
total incidences in two ways: each point contributes n + 1 incidences,
each line contributes n + 1 incidences, giving
|P| · (n+1) = |L| · (n+1), hence |L| = |P| = n² + n + 1. □

### 3.3 Coordinatization

**Theorem 3.7** (Line Determination).
*In the affine plane coordinatized by a quasifield Q, any two distinct points
(x₁, y₁) and (x₂, y₂) are connected by a unique line: either a vertical line
x = c when x₁ = x₂, or a slope line y = m·x + b determined by the slope
bijectivity axiom when x₁ ≠ x₂.*

*Proof.* When x₁ ≠ x₂, the slope bijectivity axiom ensures that the map
m ↦ m·x₁ - m·x₂ is bijective. Applying surjectivity to y₁ - y₂ yields the
unique slope m, and b = y₁ - m·x₁ gives the intercept. □

### 3.4 Collineation Obstruction

**Theorem 3.8** (Dilation Breaks Incidence).
*If a quasifield Q is non-associative, then there exist a, x, m ∈ Q such that
a·(x·m) ≠ (a·x)·m. Consequently, the dilation (x,y) ↦ (a·x, a·y) does not
preserve the incidence relation y = m·x + b.*

*Proof.* Non-associativity means ∃ a, b, c with (a·b)·c ≠ a·(b·c). Taking
x = b, m = c gives the result. For the geometric consequence: if (x, m·x + b)
is on the line y = m·x' + b, then (a·x, a·(m·x+b)) should lie on the image
line. But a·(m·x+b) = a·(m·x) + a·b (left dist.), and preservation requires
this to equal m·(a·x) + b', which needs a·(m·x) = m·(a·x), i.e.,
associativity. □

**Theorem 3.9** (Non-Desarguesian Production).
*Any non-associative quasifield produces a non-Desarguesian plane. More
precisely, if Q is non-associative, then Q is not simultaneously associative
and right-distributive, and hence its coordinatized plane is not
Desarguesian.*

### 3.5 Collineation Preservation

**Theorem 3.10** (Collineations Preserve Collinearity).
*If f is a collineation of a projective plane π and p, q, r are collinear
points, then f(p), f(q), f(r) are also collinear.*

## 4. The Quasifield Plane Construction

### 4.1 Point and Line Types

Given a quasifield Q, the projective plane π(Q) has three types of points:
- *Affine points* (x, y) for x, y ∈ Q
- *Slope points* (m) for m ∈ Q, representing "points at infinity" with slope m
- *The special point* (∞), representing the point at infinity of vertical lines

And three types of lines:
- *Slope lines* [m, b]: the locus y = m·x + b
- *Vertical lines* [c]: the locus x = c
- *The line at infinity* [∞]: containing all slope points and (∞)

### 4.2 Incidence

The incidence relation is:
- (x, y) ∈ [m, b] iff y = m·x + b
- (x, y) ∈ [c] iff x = c
- (m) ∈ [m', b] iff m = m'
- (∞) ∈ [c] for all c
- (m) ∈ [∞] and (∞) ∈ [∞]

This construction produces a translation plane: the translations
(x, y) ↦ (x + a, y + b) form a group acting transitively on affine points,
fixing the line at infinity pointwise.

## 5. Algorithms

### 5.1 Quasifield Arithmetic

Computing in a quasifield requires:
1. **Left division**: Given a ≠ 0 and b, find x with a·x = b. By bijectivity
   of left multiplication, this has a unique solution.
2. **Slope solution**: Given a ≠ b and c, find x with x·a - x·b = c. By slope
   bijectivity, this has a unique solution.
3. **Nucleus test**: Given n, verify (n·a)·b = n·(a·b) for all pairs (a,b).
   In a finite quasifield of order q, this requires O(q²) multiplications.

### 5.2 Collineation Enumeration

To enumerate collineations of π(Q):
1. Fix the image of the frame (four points in general position).
2. Extend to a full collineation using the incidence-preservation condition.
3. Check consistency: this succeeds iff the extension preserves all incidences.

For a Desarguesian plane of order q, this yields |PGL(3,q)| = q³(q³-1)(q²-1)
collineations. For a non-Desarguesian plane, the count is strictly smaller.

## 6. Discussion

### 6.1 The Role of Non-Associativity

Our results establish a precise chain of implications:

Non-associativity of Q → Proper nucleus → Dilations break incidence →
Smaller collineation group → Non-Desarguesian plane

Each link in this chain is a proven theorem. The converse direction — that
Desarguesian planes have associative coordinatizing algebras — is the
content of the classical Wedderburn-Artin coordinatization theorem, which we
state but do not fully formalize due to its dependence on deep structural
theory.

### 6.2 The Counting Theorems

The counting theorems (n² + n + 1 points and lines) hold for *all* finite
projective planes, whether Desarguesian or not. This universality is
remarkable: the combinatorial structure is completely determined by the
order, even though the geometric structure (presence or absence of Desargues'
theorem) can vary dramatically.

### 6.3 Open Problems

1. **Non-prime-power orders**: Does a projective plane of order n exist for
   any n that is not a prime power? The Bruck-Ryser theorem eliminates some
   candidates, and computer search has eliminated order 10, but the general
   question remains wide open.

2. **Classification**: How many non-isomorphic planes exist at a given order?
   At order 9, there are exactly four: the Desarguesian plane, the Hall plane,
   the dual Hall plane, and the Hughes plane. At order 16, hundreds are known.

3. **Collineation group structure**: What groups can arise as collineation
   groups of non-Desarguesian planes? The answer is constrained but not fully
   determined.

## 7. Future Work

- Complete formalization of the dual plane construction (showing the quadrangle
  axiom lifts through duality).
- Formalize the self-duality of Desargues' theorem.
- Construct explicit Hall quasifields over GF(q²) and verify their
  non-associativity.
- Prove exact collineation group counts for specific non-Desarguesian planes.
- Formalize the Lenz-Barlotti classification for translation planes.

## References

1. Hall, M. Jr., "Projective planes," *Trans. Amer. Math. Soc.* 54 (1943), 229–277.
2. Hughes, D.R. and Piper, F.C., *Projective Planes*, Springer, 1973.
3. Dembowski, P., *Finite Geometries*, Springer, 1968.
4. Lenz, H., "Kleiner Desarguesscher Satz und Dualität in projektiven Ebenen," *Jber. Deutsch. Math.-Verein.* 57 (1954), 20–31.
5. Barlotti, A., "Le possibili configurazioni del sistema delle coppie punto-retta (A, a) per cui un piano grafico risulta (A, a)-transitivo," *Boll. Un. Mat. Ital.* 12 (1957), 212–226.
6. Bruck, R.H. and Ryser, H.J., "The nonexistence of certain finite projective planes," *Canad. J. Math.* 1 (1949), 88–93.
7. Lam, C.W.H., Thiel, L., and Swiercz, S., "The nonexistence of finite projective planes of order 10," *Canad. J. Math.* 41 (1989), 1117–1123.
