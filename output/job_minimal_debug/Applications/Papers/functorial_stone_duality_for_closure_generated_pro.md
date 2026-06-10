# Functorial Stone Duality for Frames via Spectral Locales of Prime Elements

## Abstract

We present a complete, machine-verified formalization of Stone duality for frames (complete distributive lattices) in Lean 4 with Mathlib. The central result is the **Stone Separation Theorem**: in a compactly generated frame $L$, the order relation is completely determined by prime elements:

$$a \leq b \iff \forall\, p \text{ prime},\; b \leq p \implies a \leq p.$$

We prove this via Zorn's lemma and frame distributivity, building a complete spectral theory including basic-open intersection laws, prime separation, T₀ distinguishability, spectral basis structure, and contravariant functoriality of the spectrum under frame homomorphisms. All proofs are formal, machine-checked, and free of axioms beyond the standard foundations (propext, Classical.choice, Quot.sound).

**Keywords**: Stone duality, frames, prime elements, spectral spaces, Zorn's lemma, formal verification, Lean 4

---

## 1. Introduction

Stone's representation theorem (1936) established a profound connection between algebra and topology: every Boolean algebra is isomorphic to the algebra of clopen sets of a compact totally disconnected space. This duality extends far beyond Boolean algebras — to distributive lattices (Priestley duality), frames and locales (pointfree topology), and rings (Zariski spectrum). The common thread is that **order-theoretic structure is faithfully encoded in the geometry of prime elements**.

In this work, we formalize the core of this correspondence for **frames**: complete lattices satisfying infinite distributivity $a \wedge \bigvee S = \bigvee_{s \in S} (a \wedge s)$. Our main contributions are:

1. A **prime separation theorem** (Theorem 3.2): if $k$ is compact and $k \not\leq a$, there exists a prime $p$ with $a \leq p$ and $k \not\leq p$.

2. The **Stone duality theorem** (Theorem 3.4): in a compactly generated frame, $a \leq b \iff \forall p\text{ prime},\, b \leq p \implies a \leq p$.

3. A complete **spectral calculus** of basic opens: $D(a \wedge b) = D(a) \cap D(b)$, $D(a \vee b) = D(a) \cup D(b)$, monotonicity, and T₀ separation.

4. **Contravariant functoriality**: frame homomorphisms $f : L \to M$ induce spectral maps $\text{Spec}(M) \to \text{Spec}(L)$ satisfying $\text{comap}(f)^{-1}(D(k)) = D(f(k))$.

All results are formalized in approximately 400 lines of Lean 4 code across five files, building on Mathlib's order theory infrastructure.

### Motivation: Proof Semirings and Closure Geometry

Beyond its classical mathematical interest, this formalization is motivated by **proof semantics**. In the framework of closure-generated proof semirings, closure operators (nuclei) on a frame play the role of proof predicates. The lattice of nuclei is itself a frame, and our Stone duality theorem applied to this frame says:

> *Semantic consequence between proof predicates is equivalent to geometric containment across prime proof-worlds.*

This transforms proof theory into spectral geometry, where entailment becomes topological visibility and compact opens provide finite approximation schemes for consequence relations.

---

## 2. Definitions

### 2.1 Frames and Prime Elements

A **frame** is a complete lattice $L$ satisfying the infinite distributivity law:
$$a \wedge \bigvee S = \bigvee_{s \in S} (a \wedge s)$$
for all $a \in L$ and $S \subseteq L$. Every frame is a distributive lattice, and in particular satisfies:
$$(a \vee b) \wedge (a \vee c) = a \vee (b \wedge c).$$

A **prime element** of a frame $L$ is an element $p \in L$ satisfying:
1. **Properness**: $p \neq \top$
2. **Primality**: $a \wedge b \leq p \implies a \leq p \lor b \leq p$

In the lattice of ideals of a commutative ring, these are exactly the prime ideals.

### 2.2 Compact Elements and Basic Opens

An element $k \in L$ is **compact** if whenever $k \leq \bigvee S$ for a directed set $S$, there exists $s \in S$ with $k \leq s$. The lattice $L$ is **compactly generated** if every element is a supremum of compact elements below it.

The **basic open set** determined by $k \in L$ is:
$$D(k) = \{p \in \text{Spec}(L) \mid k \not\leq p\}$$

### 2.3 Specialization Order

The **specialization preorder** on prime elements is defined by:
$$p \rightsquigarrow q \iff q \leq p$$

This mirrors the topological specialization order: $p$ specializes to $q$ iff every open containing $q$ also contains $p$.

---

## 3. Main Results

### 3.1 Basic-Open Frame Laws

**Theorem 3.1** (Basic-open calculus). *For any frame $L$:*

*(a)* $D(\bot) = \emptyset$ *and* $D(\top) = \text{Spec}(L)$.

*(b)* $D(a \wedge b) = D(a) \cap D(b)$ *(meet law)*.

*(c)* $D(a \vee b) = D(a) \cup D(b)$ *(join law)*.

*(d)* $a \leq b \implies D(a) \subseteq D(b)$ *(monotonicity)*.

*Proof.* Part (b) is the most interesting. The forward direction uses $a \wedge b \leq a$ and $a \wedge b \leq b$: if $a \wedge b \not\leq p$, then neither $a \leq p$ nor $b \leq p$ (since otherwise $a \wedge b$ would be below $p$ by transitivity through a factor). The reverse direction is the contrapositive of primality. ∎

The meet law is equivalent to primality: it says exactly that $D$ sends meets to intersections, which is the content of the prime condition $a \wedge b \leq p \implies a \leq p \lor b \leq p$ applied contrapositively.

### 3.2 Prime Separation Theorem

**Theorem 3.2** (Prime extension). *Let $L$ be a frame, $k \in L$ compact, and $a \in L$ with $k \not\leq a$. Then there exists a prime element $p$ with $a \leq p$ and $k \not\leq p$.*

*Proof.* Consider the set $S = \{j \in L \mid a \leq j \land k \not\leq j\}$.

**Step 1 (Nonempty):** $a \in S$ since $a \leq a$ and $k \not\leq a$.

**Step 2 (Chain closure):** Let $C$ be a chain in $S$. Then $\bigvee C \in S$:
- $a \leq c$ for all $c \in C$, so $a \leq \bigvee C$.
- If $k \leq \bigvee C$, then by compactness of $k$ and directedness of $C$, there exists $c \in C$ with $k \leq c$, contradicting $c \in S$.

**Step 3 (Zorn):** By Zorn's lemma, $S$ has a maximal element $p$.

**Step 4 (Primality):** Suppose $x \wedge y \leq p$ but $x \not\leq p$ and $y \not\leq p$. Then $p \vee x > p$ and $p \vee y > p$. By maximality:
- $p \vee x \notin S$, so $k \leq p \vee x$ (since $a \leq p \leq p \vee x$).
- Similarly $k \leq p \vee y$.
- Therefore $k \leq (p \vee x) \wedge (p \vee y) = p \vee (x \wedge y) = p$, using frame distributivity and $x \wedge y \leq p$. This contradicts $p \in S$. ∎

The key step uses the **frame distributivity law** $(p \vee x) \wedge (p \vee y) = p \vee (x \wedge y)$, which is the algebraic engine converting maximality into primality.

### 3.3 Algebraicity Extraction

**Lemma 3.3.** *In a compactly generated frame, if $a \not\leq b$, there exists a compact $k$ with $k \leq a$ and $k \not\leq b$.*

*Proof.* Write $a = \bigvee S$ where every element of $S$ is compact and below $a$. If every $s \in S$ satisfies $s \leq b$, then $a = \bigvee S \leq b$, contradiction. ∎

### 3.4 Stone Duality Theorem

**Theorem 3.4** (Stone duality for compactly generated frames). *Let $L$ be a compactly generated frame. Then for all $a, b \in L$:*
$$a \leq b \iff \forall\, p \text{ prime},\; b \leq p \implies a \leq p.$$

*Proof.* The forward direction is transitivity. For the reverse: assume $a \not\leq b$. By Lemma 3.3, find compact $k$ with $k \leq a$ and $k \not\leq b$. By Theorem 3.2, find prime $p$ with $b \leq p$ and $k \not\leq p$. Then $b \leq p$ but $a \not\leq p$ (since $k \leq a$ and $k \not\leq p$). ∎

### 3.5 T₀ Separation

**Theorem 3.5.** *Prime elements are distinguished by basic opens: if $D(k) \ni p \iff D(k) \ni q$ for all $k$, then $p = q$.*

*Proof.* The hypothesis implies $p \rightsquigarrow q$ and $q \rightsquigarrow p$, hence $p = q$ by antisymmetry. ∎

### 3.6 Functoriality

**Theorem 3.6.** *A frame homomorphism $f : L \to M$ (preserving finite meets, top, and all joins) induces a map $f^* : \text{Spec}(M) \to \text{Spec}(L)$ defined by $f^*(p) = \bigvee \{a \in L \mid f(a) \leq p\}$, satisfying:*
1. *$f^*(p)$ is prime for every prime $p$.*
2. *$(f^*)^{-1}(D(k)) = D(f(k))$ for all $k \in L$.*

*Proof.* The map $g(b) = \bigvee\{a \mid f(a) \leq b\}$ is the right adjoint of $f$, giving a Galois connection $f(a) \leq b \iff a \leq g(b)$. For primality: if $x \wedge y \leq g(p)$, then $f(x \wedge y) = f(x) \wedge f(y) \leq p$, so $f(x) \leq p$ or $f(y) \leq p$ by primality of $p$, giving $x \leq g(p)$ or $y \leq g(p)$. The basic-open law follows from the Galois connection. ∎

---

## 4. Formalization

### 4.1 File Structure

The formalization consists of five Lean 4 files totaling approximately 400 lines:

| File | Contents | Lines |
|------|----------|-------|
| `Defs.lean` | Core definitions: `PrimeElement`, `CompactElement`, `basicOpen`, `SpectralBasis` | ~100 |
| `BasicOpen.lean` | Basic-open frame laws, specialization, T₀ separation | ~100 |
| `Separation.lean` | Prime separation (Zorn), Stone duality | ~110 |
| `Basis.lean` | Compact element closure, spectral basis instantiation | ~50 |
| `Functorial.lean` | Right adjoint, comap, basic-open preimage law | ~110 |

### 4.2 Key Design Decisions

**Working with abstract frames.** Rather than defining nuclei on a specific algebraic structure, we work with Mathlib's `Order.Frame` typeclass. This maximizes generality: our theorems apply to any frame, including lattices of ideals, lattices of nuclei, and power set lattices.

**Using `IsCompactlyGenerated`.** Mathlib provides `IsCompactlyGenerated` as a typeclass for complete lattices where every element is a supremum of compact elements. This is exactly the algebraicity condition needed for the Stone duality theorem.

**Galois connection for functoriality.** The right adjoint construction uses Mathlib's `GaloisConnection` API, which provides `le_iff_le` and `l_u_le` automatically. This makes the functoriality proofs clean and compositional.

### 4.3 Proof Techniques

The most technically demanding proof is the prime separation theorem (Theorem 3.2), which combines:
- **Zorn's lemma** (`zorn_le_nonempty₀` from Mathlib) for the maximal element
- **Compactness** (`IsCompactElement`) for chain closure
- **Frame distributivity** (`sup_inf_left`) for the maximality-to-primality step

The Zorn argument requires showing that chains in the separating set $S$ have upper bounds in $S$. This uses the compact element definition applied to the chain (which is directed) and its supremum (which is the least upper bound in a complete lattice).

---

## 5. Applications

### 5.1 Proof Theory and Semantic Consequence

The Stone duality theorem has a direct interpretation in proof theory. Consider a proof system where:
- Elements of the frame represent **proof predicates** (properties of proofs)
- The order $a \leq b$ means "predicate $a$ is a consequence of predicate $b$"
- Prime elements are **prime proof-worlds** (maximally consistent extensions)

Then the theorem states: *a predicate is a consequence of another iff it holds in every prime world where the other holds.* This is a completeness theorem for the proof system with respect to its prime-world semantics.

### 5.2 Algorithmic Entailment Checking

The compact-open basis provides an **algorithmic approximation scheme** for entailment:

1. To check $a \leq b$, decompose $a = \bigvee \{k_i\}$ into compact elements.
2. For each compact $k_i$, check $k_i \leq b$ using the finite structure of compact elements.
3. If all checks pass, $a \leq b$; otherwise, the failing $k_i$ witnesses a separating prime.

This reduces potentially infinite entailment checking to finitely many compact-element checks.

### 5.3 Tropical and Idempotent Algebra

The theory applies to **tropical semirings** where the lattice of congruences forms a frame. Prime congruences correspond to points of the tropical spectrum, and our Stone duality theorem recovers the content of tropical algebraic geometry: the geometry of a tropical variety is determined by its prime congruences.

---

## 6. Discussion: Making Abstract Algebra Visible

*A section for the general reader.*

### The Bridge Between Algebra and Geometry

Mathematics has a recurring theme: abstract algebraic structures have hidden geometric content, and making this geometry visible leads to profound insights. The most famous example is the **Zariski spectrum** of a commutative ring, where prime ideals become points of a geometric space and the algebra of the ring is encoded in the topology.

Our work extends this philosophy to **frames** — complete lattices with a strong distributivity law. Think of a frame as a "logic of properties": the elements are propositions, the order is entailment, meets are conjunctions, and joins are disjunctions. The infinite distributivity law says that conjunction distributes over infinite disjunction — a natural logical requirement.

### What Are Prime Elements?

A prime element is like a "possible world" in philosophical logic: it's a maximally consistent way to assign truth values. The primality condition — "if a conjunction entails $p$, then one of the conjuncts entails $p$" — is exactly what makes $p$ behave like a world where every proposition is either true (entailed by $p$) or false (not entailed).

### The Stone Duality Principle

The Stone duality theorem says: **two properties are logically equivalent iff they hold in exactly the same possible worlds.** More precisely, one property entails another iff every world satisfying the latter also satisfies the former. This is a completeness theorem: the "worlds" are sufficient to detect all logical distinctions.

This principle has practical consequences. In programming language theory, properties of programs (type safety, termination, resource usage) form a frame. The prime elements are "ideal program behaviors" — maximally specified computation paths. Stone duality says that reasoning about all programs reduces to reasoning about these ideal behaviors.

### The Power of Compactness

The theorem requires **compactly generated** frames — frames where every element can be built from "finite" pieces. Compactness is the bridge between infinite abstract reasoning and finite computation. It says that if a property holds at all, it holds for a finite reason — and this finite reason can be found algorithmically.

In computer science terms, compactness means that type checking, entailment verification, and proof search can be reduced to finite computations, even when the underlying domain is infinite.

### Why Machine Verification Matters

This work is fully formalized in Lean 4, meaning every logical step has been checked by a computer. This matters because:

1. **Correctness**: The Zorn's lemma argument in Theorem 3.2 involves subtle interactions between compactness, directedness, and maximality. Human-written proofs of such results occasionally contain gaps; machine verification eliminates this risk entirely.

2. **Reusability**: The formalization is structured as a library that can be imported and built upon. Future work on nuclei, tropical geometry, or proof semantics can use these results directly.

3. **Exploration**: The formal proof clarified several points that informal treatments sometimes obscure, such as the correct monotonicity direction of basic opens and the precise role of frame distributivity in the maximality-to-primality step.

---

## 7. Related Work

The mathematical content of our theorems is classical, going back to Stone (1936), Priestley (1970), and Johnstone (1982). The novelty is in the formalization approach:

- **Lean 4 / Mathlib**: We leverage Mathlib's order theory (`Order.Frame`, `IsCompactElement`, `IsCompactlyGenerated`, `GaloisConnection`) and set theory infrastructure.
- **Zorn's lemma formalization**: We use `zorn_le_nonempty₀` from Mathlib, which provides a maximal element above a given starting point.
- **Modularity**: The five-file structure separates definitions, basic laws, separation theorems, basis structure, and functoriality, making each component independently verifiable and reusable.

---

## 8. Conclusion

We have formalized the Stone duality theorem for compactly generated frames, proving that the order structure of a frame is faithfully encoded in its prime spectrum. The key innovation is the **prime separation theorem** (Theorem 3.2), which uses Zorn's lemma, compactness, and frame distributivity to construct separating primes. From this, the full Stone duality theorem and its spectral packaging follow naturally.

The formalization is complete (no sorry), sound (only standard axioms), and modular (five independent files). It provides a foundation for future work on nuclei, proof semantics, and spectral geometry of algebraic structures.

---

## References

1. Stone, M.H. "The Theory of Representations for Boolean Algebras." *Transactions of the AMS* 40(1), 1936.

2. Johnstone, P.T. *Stone Spaces.* Cambridge University Press, 1982.

3. Priestley, H.A. "Representation of Distributive Lattices by Means of Ordered Stone Spaces." *Bulletin of the LMS* 2(2), 1970.

4. Vickers, S. *Topology via Logic.* Cambridge University Press, 1989.

5. The Mathlib Community. "Mathlib: a unified library of mathematics formalized in Lean." https://github.com/leanprover-community/mathlib4
