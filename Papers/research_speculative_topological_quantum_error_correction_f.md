# Weighted Homology as the Quantitative Bridge Between Topological Quantum Codes and Combinatorial Systoles

**Aristotle**  
**July 20, 2026**

## Abstract

Topological quantum error correction is often summarized by saying that logical operators are noncontractible cycles and that code distance is the length of a shortest such cycle. This statement is correct only after the relevant identification is shown to preserve support size. We develop a finite, model-independent framework that makes this requirement explicit. A weighted homology model is a finite pointed class space equipped with a natural-number weight. Its systole is the minimum weight among nontrivial classes. We prove that pointed weight-preserving equivalences preserve nontriviality and systole, and derive the distance–systole correspondence for any homological code whose logical and geometric sectors are related by such an equivalence. We then isolate the exact hypotheses behind square-root genus scaling: if distance equals systole, squared systole is bounded by a constant times combinatorial area, and area is bounded linearly in genus, then squared distance is bounded linearly in genus. The standard square torus satisfies the exact identity $2d^2=E$, where $E$ is its edge count. Conversely, genus alone cannot bound distance, because arbitrarily fine square cellulations of a genus-one torus have unbounded distance. We also explain the complementary role of homotopy invariance of fundamental groups, present finite algorithms for computing weighted systoles and checking weighted equivalences, and discuss consequences for surface codes, color codes, higher-dimensional constructions, and speculative codes derived from algebraic varieties.

## 1. Introduction

A topological quantum code stores logical information in global degrees of freedom of a cellulated space. Physical errors are local, while nontrivial logical operators must extend across the geometry. On a surface, this often means that an undetectable logical operator is represented by an essential cycle: a loop that is not homologous to zero. The minimum support of such an operator is the code distance.

The familiar geometric slogan is therefore

$$
\text{code distance}=\text{shortest essential cycle}.
$$

Yet the equality contains more information than an abstract homology isomorphism. Homology records which cycles belong to the same class, but distance records the minimum number of physical sites in a representative. An isomorphism can preserve addition and the zero class while permuting short and long classes. Consequently, the correct bridge is an isomorphism of **weighted** class spaces.

This paper develops the finite minimum theory needed for that bridge. The framework is intentionally economical. It does not assume that classes form a vector space or group, although standard homological examples do. At the level of distance, only four ingredients are needed: a finite class set, a distinguished trivial class, a weight function, and a nontrivial class. This abstraction applies equally to logical operator sectors, first homology of a finite cell complex, and other finite topological sectors.

Our first result shows that the minimum nonzero weight exists, bounds every nonzero class, and is attained. The second shows that a pointed, weight-preserving bijection leaves this minimum unchanged. The principal coding consequence follows immediately: when logical operators are identified with first homology through such a bijection, code distance equals the combinatorial one-systole.

We next distinguish qualitative topology from quantitative geometry. Homotopy-equivalent realizations preserve fundamental groups at corresponding basepoints, ensuring compatibility of loop sectors. They need not preserve combinatorial lengths. Similarly, genus counts handles but does not control the scale or density of a cellulation. We therefore state the precise transfer theorem behind a bound of order $\sqrt{g}$ and prove a genus-one obstruction to every unnormalized genus-only bound.

The framework gives a disciplined interpretation of proposals deriving codes from algebraic varieties. Homology dimensions, by themselves, are insufficient. A quantitative construction must specify finite representatives, logical support, and a correspondence preserving or controlling weights. The distance–systole theorem then acts as an interface: construction-specific mathematics establishes the weighted identification, while the finite minimum argument transports the result to code distance.

## 2. Finite weighted homology

### 2.1. Weighted class spaces

We begin at a level general enough to encompass both logical and geometric sectors.

**Definition 2.1 (Finite weighted homology model).** A finite weighted homology model is a triple

$$
\mathcal{H}=(H,0_H,w_H),
$$

where $H$ is a finite set, $0_H\in H$ is a distinguished trivial class, and

$$
w_H:H\to\mathbb{N}
$$

is a weight function. The model is **nontrivial** if there exists $x\in H$ with $x\neq 0_H$.

The terminology “homology” emphasizes the intended application, but no algebraic operation is required for the minimum arguments below. In a cellular model, $H$ may be a homology group and $w_H(x)$ the minimum support of any cycle representing $x$. In a code model, $H$ may be the set of logical operator classes modulo stabilizers and $w_H(x)$ the minimum number of physical qubits touched by a representative.

It is not necessary to assume $w_H(0_H)=0$ for the following results, since the zero class is excluded from the minimum. In standard coding applications that equality normally holds.

**Definition 2.2 (Nonzero weight spectrum and systole).** For a nontrivial finite weighted model $\mathcal{H}$, define the nonzero weight spectrum by

$$
W^\times(\mathcal{H})=\{w_H(x):x\in H,\ x\neq 0_H\}.
$$

Its combinatorial systole is

$$
\operatorname{sys}(\mathcal{H})=\min W^\times(\mathcal{H}).
$$

When $w_H(x)$ is the least number of one-cells in a representative, this is the combinatorial one-systole.

### 2.2. Existence and extremality

**Lemma 2.3 (Lower-bound property).** Let $\mathcal{H}$ be nontrivial. For every $x\in H$ with $x\neq 0_H$,

$$
\operatorname{sys}(\mathcal{H})\leq w_H(x).
$$

**Proof sketch.** The value $w_H(x)$ belongs to the finite nonempty set $W^\times(\mathcal{H})$. The minimum of a finite nonempty set is no greater than each of its members. $\square$

**Lemma 2.4 (Attainment).** Let $\mathcal{H}$ be nontrivial. There exists $x_*\in H$ such that

$$
x_*\neq 0_H
\quad\text{and}\quad
w_H(x_*)=\operatorname{sys}(\mathcal{H}).
$$

**Proof sketch.** The set of nonzero classes is finite and nonempty. Its image under $w_H$ is therefore finite and nonempty, so its minimum belongs to the image. A preimage of that minimum is the desired class. $\square$

These elementary statements matter because they replace an informal optimization over representatives by a genuine finite extremum. They also allow the invariance theorem to be proved by comparing explicit minimizers.

## 3. Weighted equivalence and systolic invariance

### 3.1. The correct notion of identification

**Definition 3.1 (Pointed weight-preserving equivalence).** Let

$$
\mathcal{H}=(H,0_H,w_H)
\quad\text{and}\quad
\mathcal{K}=(K,0_K,w_K)
$$

be finite weighted models. A pointed weight-preserving equivalence is a bijection $f:H\to K$ satisfying

$$
f(0_H)=0_K
$$

and

$$
w_K(f(x))=w_H(x)
$$

for every $x\in H$.

We also call such a map a weighted isometry. No metric on pairs of points is implied; the term refers to exact preservation of the weight assigned to every class.

**Lemma 3.2 (Preservation of nontriviality).** If $f:\mathcal{H}\to\mathcal{K}$ is a pointed weight-preserving equivalence, then $\mathcal{H}$ is nontrivial if and only if $\mathcal{K}$ is nontrivial.

**Proof sketch.** If $x\neq 0_H$, then $f(x)\neq 0_K$; otherwise injectivity and $f(0_H)=0_K$ would imply $x=0_H$. Conversely, apply the same argument to $f^{-1}$. $\square$

**Theorem 3.3 (Systole Invariance Theorem).** Let $f:\mathcal{H}\to\mathcal{K}$ be a pointed weight-preserving equivalence between nontrivial finite weighted models. Then

$$
\operatorname{sys}(\mathcal{H})=\operatorname{sys}(\mathcal{K}).
$$

**Proof sketch.** By Lemma 2.4, choose a nonzero $x_*\in H$ attaining $\operatorname{sys}(\mathcal{H})$. Lemma 3.2 ensures that $f(x_*)$ is nonzero, and weight preservation gives

$$
w_K(f(x_*))=w_H(x_*)=\operatorname{sys}(\mathcal{H}).
$$

Lemma 2.3 applied in $\mathcal{K}$ yields

$$
\operatorname{sys}(\mathcal{K})\leq\operatorname{sys}(\mathcal{H}).
$$

Repeating the argument with $f^{-1}$ gives the reverse inequality. $\square$

### 3.2. Why unweighted isomorphism is insufficient

Consider two pointed class spaces with three classes each. Suppose their nonzero weights are $2$ and $100$ on one side and the correspondence swaps these weights on the other. As abstract pointed sets, and potentially as abstract groups, the spaces may be isomorphic. But the selected map is not weight-preserving. Quantitative conclusions about individual classes cannot be transported through it.

More generally, equal Betti numbers imply only equality of dimensions. Even a group isomorphism preserves algebraic structure rather than geometric support. The theorem therefore identifies the exact datum needed for distance: not merely an isomorphism of homology, but a weighted isometry of class sectors.

A useful approximate extension follows by the same minimizer argument. If constants $a,b>0$ satisfy

$$
a\,w_H(x)\leq w_K(f(x))\leq b\,w_H(x)
$$

for all classes, then the systoles satisfy corresponding two-sided inequalities. Exact equality is the special case $a=b=1$. This observation motivates controlled-distortion versions for subdivision maps, although our principal theorem concerns exact preservation.

## 4. Homological quantum codes

### 4.1. Abstract code model

**Definition 4.1 (Finite homological code).** A finite homological code consists of:

1. a nontrivial finite weighted logical model
   $$
   \mathcal{L}=(L,0_L,w_L),
   $$
2. a finite weighted geometric homology model
   $$
   \mathcal{H}=(H,0_H,w_H),
   $$
3. a pointed weight-preserving equivalence
   $$
   \Phi:\mathcal{L}\longrightarrow\mathcal{H}.
   $$

The quantum-code distance is

$$
d(C)=\min\{w_L(\ell):\ell\in L,\ \ell\neq 0_L\}.
$$

The definition abstracts away stabilizer presentation, coefficient field, and cell dimension. Those choices determine $L$, $H$, and $\Phi$ in concrete constructions. The theorem below concerns the quantitative consequence once these objects have been supplied.

**Theorem 4.2 (Distance–Systole Correspondence).** For every finite homological code in the sense of Definition 4.1, the geometric homology model is nontrivial and

$$
d(C)=\operatorname{sys}(\mathcal{H}).
$$

**Proof sketch.** By definition, $d(C)=\operatorname{sys}(\mathcal{L})$. Lemma 3.2 transports nontriviality from $\mathcal{L}$ to $\mathcal{H}$. Theorem 3.3 then gives

$$
\operatorname{sys}(\mathcal{L})=\operatorname{sys}(\mathcal{H}).
$$

Combining these equalities proves the claim. $\square$

This theorem gives a precise version of the statement that code distance is a systole. It also clarifies its scope. The conclusion does not assert that every topological space automatically defines a code. Nor does it construct the logical–homological identification. Rather, it proves the consequence of an identification that preserves support exactly.

### 4.2. Surface and color-code interpretations

For a surface code, physical qubits are commonly associated with edges of a cellulation. Products of Pauli operators along cycles yield logical classes modulo stabilizers generated by local boundaries or coboundaries. When this quotient is identified with first homology and support size agrees with the number of occupied edges in a minimal representative, Theorem 4.2 identifies the corresponding distance with the one-systole. A complete quantum CSS code generally has primal and dual sectors; the same argument applies to each weighted sector, with total distance given by the smaller minimum.

A color code on a trivalent, three-face-colorable cellulation admits related homological descriptions, but a mere vector-space correspondence again does not settle distance. To invoke the theorem, one must exhibit the relevant finite class space—possibly the first homology of an associated flag complex—and show that the correspondence controls support, exactly or up to a known factor.

## 5. Geometry, genus, and square-root scaling

### 5.1. Conditional transfer theorem

Distance–systole equality turns a coding question into a geometric one. To derive scaling with genus, two additional estimates are needed.

**Theorem 5.1 (Square-Root Genus Transfer Theorem).** Let $d,s,A,g,\alpha,\beta$ be nonnegative integers. Assume

$$
d=s,
$$

$$
s^2\leq \alpha A,
$$

and

$$
A\leq \beta g.
$$

Then

$$
d^2\leq \alpha\beta g.
$$

Consequently, over the nonnegative reals,

$$
d\leq \sqrt{\alpha\beta}\,\sqrt{g}.
$$

**Proof sketch.** Substitute $d=s$ into the systolic inequality and use monotonicity under multiplication by the nonnegative integer $\alpha$:

$$
d^2=s^2\leq \alpha A\leq \alpha\beta g.
$$

Taking nonnegative square roots gives the second form. $\square$

The theorem separates three logically independent ingredients. The equality $d=s$ is the coding-to-geometry bridge. The inequality $s^2\leq\alpha A$ is a geometric systolic estimate. The bound $A\leq\beta g$ normalizes the size of the cellulation relative to topology. Omitting any ingredient breaks the stated conclusion.

### 5.2. Exact square-torus relation

Let the standard square torus be formed from an $n\times n$ periodic grid. There are $n^2$ horizontal edges and $n^2$ vertical edges, giving

$$
E=2n^2.
$$

A shortest essential horizontal or vertical cycle contains $n$ edges. Under the standard support identification, $d=n$.

**Proposition 5.2 (Square Torus Distance–Area Identity).** If a square torus has distance $d=n$ and edge count $E=2n^2$, then

$$
2d^2=E.
$$

**Proof sketch.** Substitute $d=n$ into $2d^2$ and compare with the stated edge count. $\square$

Thus this family realizes an exact square-root law relative to edge count:

$$
d=\sqrt{E/2}.
$$

For $n=2,3,5,8$, the pairs $(E,d)$ are $(8,2)$, $(18,3)$, $(50,5)$, and $(128,8)$.

### 5.3. Genus-only obstruction

The square torus also disproves an unnormalized genus law. Its genus remains $1$ as $n$ increases, while the distance grows with $n$.

**Theorem 5.3 (No Genus-Only Distance Bound).** For every nonnegative integer $B$, there exist numerical surface-code parameters $d$ and $g$ satisfying

$$
g=1
\quad\text{and}\quad
B<d.
$$

In particular, no finite bound depending only on genus can control distance across arbitrarily refined genus-one cellulations.

**Proof sketch.** Set $g=1$ and $d=B+1$. The square torus family realizes arbitrarily large values of $d$ while retaining genus $1$, so these parameters correspond to increasingly refined toroidal cellulations. $\square$

This theorem does not conflict with Theorem 5.1. Rather, it explains why the area hypothesis in that theorem is necessary. At fixed genus, the edge count $E=2n^2$ is unbounded; hence no constant $\beta$ can satisfy $E\leq\beta g$ across the entire refinement family.

The mathematically meaningful $O(\sqrt{g})$ prediction therefore concerns normalized families, such as bounded-degree cellulations with area at most a fixed multiple of genus, together with a uniform systolic inequality.

## 6. Homotopy compatibility and metric instability

Topological code constructions should be stable under changes that preserve the underlying topology. Homotopy equivalence supplies a standard qualitative certificate.

**Theorem 6.1 (Fundamental-Group Compatibility).** Let $X$ and $Y$ be homotopy-equivalent topological spaces. For every basepoint $x\in X$, there exists a corresponding basepoint $y\in Y$ such that the fundamental groups are isomorphic:

$$
\pi_1(X,x)\cong\pi_1(Y,y).
$$

**Proof sketch.** A homotopy equivalence has a homotopy inverse. The induced maps on fundamental groups compose to the identity up to the standard basepoint transport, yielding mutually inverse group homomorphisms. $\square$

This theorem supports cellulation-independent construction of qualitative loop sectors. Abelianizing and choosing coefficients can then lead to first homology. However, it does not preserve combinatorial support. A subdivision may replace one edge by a long edge path while leaving the homotopy type unchanged. The fundamental group and homology can remain isomorphic even as the one-systole changes by an arbitrarily large factor.

Accordingly, topological invariance and metric invariance play complementary roles. Homotopy equivalence establishes that the class structure is unchanged. A weighted isometry, or a controlled-distortion map, establishes that distance is unchanged or quantitatively comparable.

## 7. Algorithms

### 7.1. Computing a finite weighted systole

Given an explicit finite list of classes, a distinguished zero class, and a weight table, the systole can be computed by a single scan.

**Algorithm 7.1 (Finite Nontrivial Minimum).**

1. Initialize the current minimum as undefined.
2. For each class $x$, skip $x$ if $x=0_H$.
3. Otherwise compare $w_H(x)$ with the current minimum and retain the smaller value.
4. If no nonzero class was encountered, report that the model is trivial.
5. Return the minimum and one class attaining it.

For $N=|H|$, the algorithm uses $O(N)$ weight evaluations and $O(1)$ auxiliary storage, apart from the input. This is optimal in the comparison model because an unseen class could have smaller weight.

### 7.2. Checking a proposed weighted equivalence

Suppose finite models $H$ and $K$ and a candidate map $f:H\to K$ are explicit.

**Algorithm 7.2 (Pointed Weighted-Isometry Test).**

1. Check that $f(0_H)=0_K$.
2. Insert every image $f(x)$ into a set, rejecting duplicate images.
3. Verify that every element of $K$ appears and that $|H|=|K|$.
4. For every $x\in H$, verify $w_K(f(x))=w_H(x)$.
5. Accept exactly when all checks pass.

With hashable classes and constant-time weight access, expected time is $O(|H|+|K|)$ and space is $O(|K|)$. Sorting-based implementations require $O(N\log N)$ time.

### 7.3. Genus-bound certification

For concrete integers $d,s,A,g,\alpha,\beta$, a certificate checker verifies the three hypotheses of Theorem 5.1 and computes the slack

$$
\alpha\beta g-d^2.
$$

All operations are constant in the number of inputs, though their bit complexity is polynomial in the bit lengths. This checker does not discover a systolic inequality; it validates a proposed finite instance of the transfer theorem.

## 8. Applications and interpretation

### 8.1. Surface-code design

The results suggest a modular design strategy. First, establish the algebraic classification of logical operators. Second, identify those classes with geometric cycles. Third, prove that the identification preserves minimal support. Fourth, import or prove a systolic inequality suited to the cellulation family. Finally, normalize area against genus or another family parameter.

This modularity prevents a common category error: using a statement about the number of homology classes as though it controlled the length of their representatives. The class space determines what logical operators exist; the weight function determines resilience against local errors.

### 8.2. Algebraic varieties

A speculative arithmetic program would begin with a smooth projective variety, select a finite cellular or simplicial model, and use an appropriate homology group to label logical sectors. Several additional steps are unavoidable:

- a finite physical-qubit architecture must be specified;
- stabilizers and logical equivalence must be defined;
- geometric classes must be connected to logical classes;
- representative size must correspond to operator support;
- reduction or specialization must control weights, not only homology ranks.

The present results do not assert that every algebraic variety supplies these data. They isolate the sufficient quantitative bridge. If a family over a number field admits reductions for which weighted homology spectra are preserved up to controlled scaling, the same control transfers immediately to code distance.

### 8.3. Higher dimensions

For cellular CSS codes on a closed $d$-manifold, logical operators may arise from cycles in dimension $k$ and complementary dual cycles in dimension $d-k$. The natural extension replaces the one-systole by $k$-dimensional combinatorial systoles. The finite weighted-isometry argument itself is dimension-free: once each class has a finite support weight, its minimum transports through a pointed weight-preserving equivalence. The substantial new work lies in proving duality-compatible identifications and geometric inequalities for higher-dimensional systoles.

## 9. Discussion and limitations

The framework provides exact conclusions from exact hypotheses. Its principal strength is also its limitation: it deliberately leaves construction-specific geometry outside the abstract theorem. It does not derive cellulations from varieties, prove that arbitrary homology classes act as logical operators, or supply universal systolic inequalities.

Three cautions are central.

First, finite weighted homology is stronger than finite homology. Two models with the same class count and algebraic structure can differ in their weight spectra. Quantitative coding statements must therefore retain support information.

Second, homotopy invariance is qualitative. It protects fundamental-group and homology structure but not combinatorial lengths. Uniformly bounded local subdivision degree is a plausible sufficient condition for bounded weight distortion; unrestricted refinement is not.

Third, genus scaling requires size normalization. Theorem 5.3 shows that a fixed torus already defeats every genus-only bound. A square-root genus theorem must quantify local degree, area, and systolic constants.

These cautions sharpen rather than weaken the topological-code program. They convert broad slogans into a checklist of mathematical obligations and indicate where new geometry or arithmetic is genuinely needed.

## 10. Future directions

Several directions follow naturally.

**Arithmetic persistence of weighted homology.** For varieties and normal-crossings cell models defined over number fields, one may ask whether good reduction preserves the complete minimum-weight spectrum, perhaps after uniform rescaling. Stability of Betti numbers is not enough; representative costs must also be controlled.

**Higher-dimensional distance–systole duality.** Cellular CSS codes on closed manifolds should admit paired descriptions in complementary dimensions. Establishing naturality under bounded-degree subdivisions would connect topological invariance with metric control.

**Sharp bounded-geometry genus laws.** Under upper and lower bounds on vertex and face degrees and an edge count linear in genus, one expects an upper bound $d\leq C\sqrt{g}$ and families attaining $d\geq c\sqrt{g}$. The genus-one refinement obstruction identifies why all these normalization hypotheses matter.

**Color-code flag-complex isometry.** A useful target is a support-controlled correspondence between a color-code logical sector and first homology of an explicit flag complex, potentially with a universal distortion factor of two.

**Homotopy stability with metric instability.** Infinite families of homotopy-equivalent finite complexes can share fundamental groups and mod-two first homology while their combinatorial systoles diverge. Determining precise local conditions that prevent this divergence would delimit the natural domain of robust topological code equivalence.

## 11. Conclusion

The quantitative invariant behind topological quantum-code distance is not homology dimension alone. It is the minimum nonzero value in a weighted homology spectrum. Once logical and geometric class spaces are connected by a pointed weight-preserving equivalence, their minima agree, and code distance becomes exactly the combinatorial systole.

This transport principle cleanly separates coding theory from geometry. It turns support preservation into the required bridge, systolic inequalities into distance bounds, and area normalization into the missing condition behind square-root genus scaling. The square torus illustrates both sides: it obeys the exact relation $2d^2=E$, yet its arbitrarily fine genus-one refinements rule out every bound based on genus alone.

For future constructions—from colorable complexes to higher-dimensional manifolds and arithmetic varieties—the design criterion is therefore precise: classify the classes, retain their weights, and control the map between them. Topology determines which logical loops exist; weighted geometry determines how well they protect information.
