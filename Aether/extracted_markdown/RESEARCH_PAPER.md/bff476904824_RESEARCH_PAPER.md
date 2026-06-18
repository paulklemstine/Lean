# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

## Abstract

We develop a framework for number theory on the Poincaré disk model of hyperbolic geometry. The central objects are *hyperbolic integers* — orbit points of a basepoint under a discrete group of Blaschke factors — and *hyperbolic primes* — orbit points that are indecomposable under composition. We establish the foundational analytic-algebraic machinery: the Blaschke normSq identity, the disk preservation theorem, symmetry and definiteness of the hyperbolic pseudo-distance, and closure of lattice orbits within the disk. We define a counting function for lattice points and formulate a falsifiable conjecture on its growth rate. All core results are formalized in Lean 4 with machine-verified proofs.

**Keywords**: Poincaré disk, Blaschke factor, hyperbolic lattice, Möbius transformation, hyperbolic prime, pseudo-distance, lattice point counting

---

## 1. Introduction

Classical number theory studies the integers $\mathbb{Z}$ embedded in the real line $\mathbb{R}$, with arithmetic operations inherited from the ambient field. The distribution of primes among the integers is governed by the Prime Number Theorem and, conjecturally, by the Riemann Hypothesis.

A natural question arises: what happens to arithmetic when the ambient space is curved? The Poincaré disk $\mathbb{D} = \{z \in \mathbb{C} : |z| < 1\}$ is the canonical model of 2-dimensional hyperbolic geometry. Its isometry group consists of Möbius transformations of the form $z \mapsto e^{i\theta}\frac{z-a}{1-\bar{a}z}$, which we decompose into a rotation factor $e^{i\theta}$ and a *Blaschke factor* $\varphi_a(z) = \frac{z-a}{1-\bar{a}z}$.

We define hyperbolic integers as orbit points under discrete subgroups of the automorphism group, and develop the foundational theory needed for counting and factoring these objects.

## 2. Definitions

### 2.1 The Blaschke Factor

**Definition 1** (Blaschke Factor). For $a \in \mathbb{D}$, the Blaschke factor is:
$$\varphi_a(z) = \frac{z - a}{1 - \bar{a}z}$$

### 2.2 Hyperbolic Pseudo-Distance

**Definition 2** (Hyperbolic Pseudo-Distance). For $z, w \in \mathbb{C}$:
$$\delta(z, w) = \frac{|z - w|^2}{|1 - \bar{w}z|^2}$$

This is related to the standard Poincaré metric $d(z,w)$ by $\delta(z,w) = \tanh^2(d(z,w)/2)$.

### 2.3 Hyperbolic Lattice

**Definition 3** (Hyperbolic Lattice). A hyperbolic lattice $\Lambda$ consists of:
- A set of *centers* $\mathcal{C} \subset \mathbb{D}$
- A *basepoint* $z_0 \in \mathbb{D}$
- The *orbit* $\Lambda = \{\varphi_a(z_0) : a \in \mathcal{C}\}$

### 2.4 Hyperbolic Primes

**Definition 4** (Hyperbolic Prime). A point $p \in \Lambda$ is a *hyperbolic prime* if $p \neq z_0$ and for all $b, c \in \Lambda$, if $p = \varphi_b(c)$ then $b = z_0$ or $c = z_0$.

This captures the notion of irreducibility under the group action: a prime cannot be non-trivially factored as a composition of lattice transformations.

### 2.5 Counting Function

**Definition 5** (Counting Function). For $R > 0$:
$$N_\Lambda(R) = |\{w \in \Lambda : \delta(w, z_0) \leq R\}|$$

## 3. Main Results

### 3.1 The Blaschke NormSq Identity

**Theorem 1** (Blaschke NormSq Identity). *For all $z, a \in \mathbb{C}$:*
$$|z - a|^2 - |1 - \bar{a}z|^2 = (|z|^2 - 1)(1 - |a|^2)$$

*Proof sketch.* Direct algebraic expansion. Writing $|z-a|^2 = |z|^2 - 2\text{Re}(\bar{a}z) + |a|^2$ and $|1 - \bar{a}z|^2 = 1 - 2\text{Re}(\bar{a}z) + |a|^2|z|^2$, the difference simplifies to $(|z|^2 - 1) - |a|^2(|z|^2 - 1) = (|z|^2-1)(1-|a|^2)$. ∎

### 3.2 Disk Preservation

**Theorem 2** (Disk Preservation). *If $|z| < 1$ and $|a| < 1$, then $|\varphi_a(z)| < 1$.*

*Proof sketch.* The denominator $1 - \bar{a}z \neq 0$ since $|\bar{a}z| = |a||z| < 1$. By Theorem 1, $|z-a|^2 < |1-\bar{a}z|^2$ (the difference $(|z|^2-1)(1-|a|^2)$ is negative), so $|\varphi_a(z)| = |z-a|/|1-\bar{a}z| < 1$. ∎

**Corollary** (Composition Closure). *If $|z| < 1$, $|a| < 1$, $|b| < 1$, then $|\varphi_b(\varphi_a(z))| < 1$.*

### 3.3 Special Values

**Theorem 3**. *$\varphi_a(a) = 0$ and $\varphi_a(0) = -a$.*

These characterize the Blaschke factor as the unique disk automorphism sending $a$ to the origin (up to rotation).

### 3.4 Properties of Hyperbolic Pseudo-Distance

**Theorem 4** (Pseudo-Metric Properties). *For $z, w \in \mathbb{D}$:*
1. *(Reflexivity)* $\delta(z, z) = 0$
2. *(Symmetry)* $\delta(z, w) = \delta(w, z)$
3. *(Definiteness)* $\delta(z, w) = 0 \iff z = w$
4. *(Non-negativity)* $0 \leq \delta(z, w)$
5. *(Boundedness)* $\delta(z, w) < 1$

*Proof of symmetry.* We must show $\frac{|z-w|^2}{|1-\bar{w}z|^2} = \frac{|w-z|^2}{|1-\bar{z}w|^2}$. The numerators are equal since $|z-w|^2 = |-(w-z)|^2 = |w-z|^2$. For the denominators, $\overline{1 - \bar{w}z} = 1 - w\bar{z} = 1 - \bar{z}w$ (using commutativity), so $|1-\bar{w}z|^2 = |1-\bar{z}w|^2$. ∎

*Proof of definiteness.* If $\delta(z,w) = 0$, then $|z-w|^2 = 0$ (since the denominator is positive), so $z = w$. Conversely, $\delta(z,z) = 0$ is immediate. ∎

### 3.5 Lattice Orbit Theorem

**Theorem 5** (Orbit Closure). *Every point in the orbit of a hyperbolic lattice lies in $\mathbb{D}$.*

*Proof.* Immediate from Theorem 2 and the definition of the lattice (all centers lie in $\mathbb{D}$). ∎

## 4. Algorithms

### 4.1 Lattice Point Enumeration

Given generators $a_1, \ldots, a_k \in \mathbb{D}$ and a basepoint $z_0 \in \mathbb{D}$, we enumerate lattice points by breadth-first application of Blaschke factors and their inverses:

```
ENUMERATE(generators, basepoint, max_depth):
    queue ← {basepoint}
    visited ← {basepoint}
    for depth = 1 to max_depth:
        new_points ← {}
        for z in queue:
            for a in generators:
                w ← φ_a(z)
                w' ← φ_a⁻¹(z)  // Note: φ_a⁻¹ = φ_{-a}
                if w ∉ visited: add w to new_points, visited
                if w' ∉ visited: add w' to new_points, visited
        queue ← new_points
    return visited
```

### 4.2 Hyperbolic Prime Detection

A lattice point $p$ is tested for primality by checking whether it admits a non-trivial decomposition:

```
IS_PRIME(p, lattice_points, basepoint, tolerance):
    for b in lattice_points:
        for c in lattice_points:
            if b ≠ basepoint and c ≠ basepoint:
                if |p - φ_b(c)| < tolerance:
                    return False
    return True
```

## 5. Conjecture

**Conjecture** (Hyperbolic Lattice Growth). For any hyperbolic lattice $\Lambda$ with finitely many generators, there exists $C > 0$ such that $N_\Lambda(R) \leq C \cdot R^2$ for all $R > 0$.

**Testable prediction**: Generate the lattice with centers $a_1 = 1/2$, $a_2 = i/2$, $a_3 = (1+i)/3$ and basepoint $z_0 = 0$. Compute $N_\Lambda(R)$ for $R = 0.1, 0.2, \ldots, 0.9$. The data should be well-fitted by a quadratic $CR^2$.

**Remark**: In the classical (Euclidean) setting, the Gauss circle problem gives $N(R) = \pi R^2 + O(R^{2/3+\varepsilon})$. The hyperbolic analogue is more subtle because hyperbolic area grows exponentially with the geodesic radius, but the pseudo-distance $\delta$ is bounded by 1, compressing the counting window.

## 6. Discussion

### 6.1 Relation to Selberg Zeta Functions

The lattice point counting problem for Fuchsian groups is classical (Huber, 1956; Patterson, 1976). For cofinite Fuchsian groups $\Gamma$, the number of orbit points $\gamma z_0$ with $d(z_0, \gamma z_0) \leq T$ grows like $e^T$ as $T \to \infty$, with the error term controlled by the spectral gap of the Laplacian on $\Gamma \backslash \mathbb{H}$. Our framework reformulates this in terms of the pseudo-distance $\delta$, which transforms the exponential growth into a more tractable form.

### 6.2 Unique Factorization

The question of unique factorization in hyperbolic arithmetic is delicate. In free groups, words have unique reduced forms, giving a trivial form of unique factorization. For groups with relations (e.g., $\text{PSL}(2,\mathbb{Z})$, which has the presentation $\langle S, T | S^2 = (ST)^3 = 1 \rangle$), the situation is more subtle and connects to the word problem for finitely presented groups.

### 6.3 Hyperbolic Zeta Functions

The Selberg zeta function $Z_\Gamma(s) = \prod_{p} \prod_{k=0}^{\infty} (1 - e^{-(s+k)\ell(p)})$, where the outer product runs over primitive closed geodesics $p$ of length $\ell(p)$, is the natural analogue of the Riemann zeta function. Its zeros encode the spectrum of the Laplacian on $\Gamma \backslash \mathbb{H}$, and the analogue of the Riemann Hypothesis would be a spectral gap statement.

## 7. Related Work

The arithmetic of Fuchsian groups has been studied extensively in the context of arithmetic surfaces (Shimura, 1971; Vignéras, 1980). The connection between lattice point counting and spectral theory goes back to Selberg's trace formula (1956). More recently, hyperbolic lattice point problems have found applications in quantum chaos (Sarnak, 1995) and the theory of automorphic forms.

Our contribution is to frame these classical objects in the language of "hyperbolic number theory," making the analogy with classical arithmetic explicit and computationally tractable, with machine-verified foundational results.

## 8. Conclusion

We have established the rigorous foundations for arithmetic on the Poincaré disk: the Blaschke normSq identity, disk preservation, pseudo-distance properties, and lattice orbit structure. These results, formalized with machine-verified proofs, provide a reliable base for further investigations into hyperbolic primes, counting functions, and zeta functions.

The most exciting open questions concern the distribution of hyperbolic primes and the relationship between lattice growth rates and spectral data. The Gauss circle problem in hyperbolic space remains largely unexplored for general discrete groups, and our framework provides both the definitions and the computational tools to make progress.

## References

1. Huber, H. (1956). Über eine neue Klasse automorpher Funktionen und ein Gitterpunktproblem in der hyperbolischen Ebene. *Commentarii Mathematici Helvetici*, 30, 20–62.
2. Patterson, S. J. (1976). The Laplacian operator on a Riemann surface. *Compositio Mathematica*, 31(1), 83–107.
3. Sarnak, P. (1995). Arithmetic quantum chaos. *Israel Mathematical Conference Proceedings*, 8, 183–236.
4. Selberg, A. (1956). Harmonic analysis and discontinuous groups in weakly symmetric Riemannian spaces. *Journal of the Indian Mathematical Society*, 20, 47–87.
5. Shimura, G. (1971). *Introduction to the Arithmetic Theory of Automorphic Functions*. Princeton University Press.
6. Vignéras, M.-F. (1980). *Arithmétique des algèbres de quaternions*. Springer.
