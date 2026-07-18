# Gravity from Information? What Quantum Codes Really Say About Geometry

## A bold idea meets a sharp inequality

Imagine that space is not merely a stage on which information lives, but an information-protecting structure in its own right. In this picture, the microscopic degrees of freedom of a spatial region resemble the physical qubits of a quantum error-correcting code. The information that survives local damage resembles logical qubits. A shortest undetectable error resembles a geometric path through the region. This analogy is one of the most evocative bridges between quantum information and gravity.

But evocative bridges need load tests. A proposed dictionary identifies three integers from a quantum code with geometric quantities: $n$ counts physical units, $k$ counts protected logical qubits, and $d$ measures the smallest error capable of corrupting the protected information. In standard notation this is an $[[n,k,d]]$ quantum code. The intended geometric reading treats $n$ as a boundary size in microscopic units, $k$ as an entropy measured in qubits, and $d$ as half a characteristic geometric length.

The key coding constraint is the **quantum Singleton bound**:

$$
2d+k\le n+2.
$$

Equivalently, when $k\le n$ and $d\ge 1$, it may be written

$$
2(d-1)\le n-k.
$$

The left side measures how much redundancy distance demands; the right side is the number of physical qubits not used as logical qubits. The inequality says that robust protection is never free.

This simple bound delivers both an attractive possibility and a decisive warning. The possibility is that equality can turn a coding constraint into an exact entropy-like formula. The warning is that an inequality is not automatically an identity. Under the most direct proposed length dictionary, the bound actually prevents entropy from growing with size.

## Validity is not saturation

Suppose the Singleton bound is saturated:

$$
2d+k=n+2.
$$

Then, and only then on the basis of this bound alone, one obtains the exact capacity identity

$$
k=n-2d+2.
$$

This distinction matters. Every code below the Singleton ceiling satisfies the inequality, but only a code on the ceiling satisfies the displayed identity. Therefore, an exact geometric entropy formula cannot be derived merely by citing the Singleton bound. One must separately establish saturation.

A familiar analogy is a speed limit. Knowing that a car travels at no more than $100$ kilometers per hour does not show that it travels at exactly $100$. Likewise, $2d+k\le n+2$ does not show that $2d+k=n+2$. Any proposal identifying a geometric entropy formula with a coding theorem must explain why the relevant family of codes is optimal in precisely this sense.

## The quantity that controls capacity

The arithmetic becomes especially transparent after defining the **geometric defect** $\delta$ by

$$
n=2d+\delta,
$$

where $\delta\ge 0$. The defect is the excess of physical size over twice the code distance. Substitute this equation into the Singleton bound:

$$
2d+k\le 2d+\delta+2.
$$

Canceling $2d$ gives the central result.

**Defect–Capacity Theorem.** For every quantum code obeying the Singleton bound and satisfying $n=2d+\delta$, the logical capacity obeys

$$
k\le \delta+2.
$$

The proof is a single substitution, but its interpretation is substantial. Physical size $n$ by itself does not control logical capacity. Distance consumes roughly half the available size twice over, and only the residual defect remains available for logical information, apart from the universal additive allowance of two qubits.

Each additional unit of defect can increase the Singleton ceiling on $k$ by at most one. Conversely, if an application demands at least $m$ logical qubits, then

$$
m\le k\le \delta+2,
$$

so necessarily

$$
\delta\ge m-2
$$

whenever ordinary integer subtraction applies. Extensive protected information therefore requires extensive defect.

## The exact-balance surprise

Now impose the proposed geometric dictionary in its most rigid form:

$$
n=2d.
$$

This is exact balance, corresponding to $\delta=0$. The Defect–Capacity Theorem immediately yields the **Balanced Capacity Bound**:

$$
k\le 2.
$$

No matter how large $n$ becomes, a Singleton-valid family at exact balance can encode at most two logical qubits. A code with $k\ge 3$ and $n=2d$ cannot obey the quantum Singleton bound.

This is the opposite of an area-growing entropy. If $n$ represents a boundary length or area in microscopic units and $k$ represents protected entropy, then scaling the boundary while preserving $n=2d$ does not create increasing protected capacity. Both $n$ and $d$ grow, but their growth cancels in the bound.

At exact balance, Singleton saturation is also completely characterized.

**Balanced Saturation Theorem.** If $n=2d$, then

$$
2d+k=n+2
$$

holds exactly when $k=2$.

Thus two logical qubits are not merely an upper bound at balance; they are the unique capacity at which the bound is saturated.

## A sign reversal that changes everything

It is easy to reverse the redundancy inequality by accident. The genuine Singleton form is

$$
2(d-1)\le n-k.
$$

The reversed relation would be

$$
n-k\le 2(d-1).
$$

Under $n=2d$, with $d\ge1$ and $k\le n$, this reversed relation is equivalent to

$$
2\le k.
$$

Meanwhile, the genuine Singleton inequality gives $k\le2$. If both are imposed, they force

$$
k=2.
$$

This explains why a mistaken direction can sometimes appear numerically compatible with a special answer: paired with the correct bound at exact balance, it collapses the permitted interval to one point. It does not establish a broad entropy law. It establishes a rigid corner case.

## Families of larger and larger codes

The defect viewpoint becomes more revealing for a sequence of codes. Suppose every member obeys Singleton, and suppose its defect never exceeds a fixed number $D$:

$$
n_i=2d_i+\delta_i,
\qquad
\delta_i\le D.
$$

Then every member obeys

$$
k_i\le D+2.
$$

This is the **Bounded-Defect Family Theorem**. Growing the physical system cannot make its protected logical capacity unbounded while the defect stays bounded.

There is also an asymptotic statement. The logical rate is the fraction $k_i/n_i$. Given any tolerance $\varepsilon>0$, once the physical size is sufficiently large—one may take any threshold greater than $(D+2)/\varepsilon$—the rate satisfies

$$
\frac{k_i}{n_i}<\varepsilon.
$$

So bounded defect forces the logical rate toward zero as physical size grows. This is not a claim that large systems cannot store information. It says that systems constrained simultaneously by Singleton and near-exact balance cannot maintain a positive fraction of protected logical information.

A concrete example makes the cancellation visible. Take $n=1000$ and $d=500$. Exact balance gives $k\le2$. Doubling to $n=2000$ and $d=1000$ still gives $k\le2$. If instead the second system has defect $\delta=100$, so $n=2d+100$, then $k\le102$. The available logical capacity tracks the defect, not the total size.

## What this says—and what it does not

The analysis identifies a precise test for proposals connecting coding and geometry. If a geometric entropy is to equal a Singleton expression, the associated code must saturate the bound. If the proposed dictionary imposes $n=2d$, then protected entropy is bounded by two qubits. To obtain entropy that grows with geometric size, at least one ingredient must change: the distance dictionary, the identification of entropy with $k$, the use of a single global code, or the assumption that Singleton alone supplies the desired identity.

This does not construct a spacetime code. It does not show that geodesic length equals code distance, that curvature is a decoding response, or that matter is an error syndrome. Those are physical hypotheses requiring a concrete encoding map, locality structure, noise model, and dynamical predictions. Parameter arithmetic can test consistency, but it cannot create the missing physics.

The result nevertheless points toward a more refined research program. It also offers a practical virtue: any candidate model can be screened before difficult dynamics are attempted. Its proposed size, distance, and entropy assignments can be placed into the inequality, and an inconsistency will appear immediately rather than being hidden behind an appealing analogy. In holographic settings, entropy is associated with regions and cuts, not merely with one global triple $[[n,k,d]]$. A plausible coding account may therefore require a family of cut-dependent inequalities, with an entropy–area equality corresponding to simultaneous or structured saturation. Spatial variation of a local defect could carry geometric information that a single constant defect cannot.

## The deeper lesson

The dream that gravity emerges from information remains compelling because error correction explains how global information can survive local disturbance. Yet the Singleton bound teaches a disciplined version of that dream. Robustness, capacity, and physical size are linked, but not interchangeable. An inequality supplies a ceiling; an identity requires optimality. A geometric dictionary is an assumption; its consequences must be followed even when they resist the intended story.

The decisive quantity here is

$$
\delta=n-2d,
$$

understood through the nonnegative relation $n=2d+\delta$. It measures what remains after distance has claimed its share of the physical system. The resulting law,

$$
k\le\delta+2,
$$

is a compact audit of any proposed geometry-to-code translation. At exact balance it permits only constant capacity. Under bounded defect it drives the asymptotic rate to zero. Under extensive entropy demand it requires extensive defect.

If spacetime is to behave like a quantum code, then geometry must do more than provide many microscopic degrees of freedom. It must provide the right excess between size and distance—or replace the global dictionary with a richer, region-dependent one. That is not the end of the information-theoretic approach to gravity. It is the beginning of a sharper one.