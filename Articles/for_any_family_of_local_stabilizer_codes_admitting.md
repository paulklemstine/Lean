# The Two-Qubit Correction: A Capacity Law for Quantum Codes

## The budget hidden inside error correction

A quantum computer cannot simply copy fragile information and keep a spare. The no-cloning principle forbids that familiar strategy. Instead, a quantum error-correcting code spreads a smaller logical system across a larger physical one so that damage to part of the hardware can be detected and repaired. This creates a three-way negotiation among physical size, protected information, and resilience.

The standard notation $[[n,k,d]]$ records those three quantities. The code uses $n$ physical qubits to carry $k$ logical qubits, while its distance $d$ measures protection: in the usual error-correction interpretation, larger $d$ permits the code to detect or correct more severe errors. The central question is not merely how large each parameter can be, but how they constrain one another.

One of the sharpest universal constraints is the quantum Singleton inequality,

$$
k+2(d-1)\le n.
$$

At first glance this is an austere bookkeeping rule. Yet a simple rearrangement reveals a useful capacity variable. Define the **exact Singleton defect** by

$$
D=n+2-2d.
$$

Then the Singleton inequality becomes

$$
0\le k\le D.
$$

The quantity $D$ is the budget left for logical information after distance has consumed its share of the physical system. The result is elementary in algebraic form but powerful in interpretation: no code satisfying the Singleton inequality can protect more than $D$ logical qubits.

There is a subtle two-qubit correction here. Geometry often suggests considering the more visually immediate balance

$$
G=n-2d,
$$

which we call the **geometric defect**. But $G$ is not the exact finite-size capacity budget. The two defects satisfy

$$
D=G+2.
$$

That constant matters for a single small code. It becomes negligible for a growing family, where division by $n$ turns it into $2/n$. Distinguishing these two scales—exact finite size and asymptotic density—is the key to the whole story.

## Distance spends physical qubits

Imagine $n$ physical qubits as a fixed construction budget. A demand for distance $d$ reserves roughly $2d$ units of that budget for protection. What remains can host logical information. The Singleton inequality makes that metaphor precise, including the endpoint correction:

$$
k\le n+2-2d.
$$

This does not say how to build a good code. Nor does it say that every available unit of defect can actually be converted into a logical qubit. It says something more universal and one-sided: defect is necessary capacity. If the budget is absent, extensive logical storage is impossible.

The distinction between necessity and sufficiency is crucial. A building may have enough floor area for a laboratory without possessing the wiring, ventilation, or structural layout needed to operate one. Likewise, a code may have a large Singleton defect without possessing the algebraic and geometric structure required to realize a large logical space. Locality, check geometry, and decoding architecture can impose further restrictions. The defect gives a ceiling, not a construction recipe.

The same ceiling applies to any operationally meaningful protected entropy $S$ that is bounded by the number of logical qubits. If

$$
S\le k,
$$

then automatically

$$
S\le D=n+2-2d.
$$

Thus the defect controls not only the nominal logical dimension but every nonnegative information measure whose value cannot exceed $k$. Depending on the application, $S$ might represent reliably stored quantum information, an encoded entropy measured in qubits, or another protected resource constrained by the logical subsystem.

## Exact balance forbids extensive information

The most striking consequence appears for families of larger and larger codes. Suppose the physical size $n_i$ tends to infinity, while the geometric defect

$$
G_i=n_i-2d_i
$$

stays below a fixed constant $B$. Then the exact defect obeys

$$
D_i=G_i+2\le B+2,
$$

and therefore

$$
k_i\le B+2.
$$

No matter how large the hardware becomes, the number of logical qubits remains uniformly bounded. Dividing by the growing block length gives

$$
0\le \frac{k_i}{n_i}\le \frac{B+2}{n_i}\longrightarrow 0.
$$

This is the **bounded-defect zero-rate principle**: a family balanced near $n_i=2d_i$ cannot have a positive asymptotic logical rate. Physical growth alone does not produce extensive storage if distance grows so aggressively that only a bounded defect remains.

The same argument applies to protected entropy. If $0\le S_i\le k_i$, then

$$
0\le \frac{S_i}{n_i}\le \frac{B+2}{n_i}\longrightarrow 0.
$$

So bounded defect rules out extensive protected entropy as well as extensive logical dimension. A family can become enormous while its protected information density evaporates.

Consider a simple parameter sequence with $n_i=2i$, $d_i=i$, and $k_i=2$. Here $G_i=0$ and $D_i=2$. The code parameters, if realized, sit at the exact upper budget $k_i=D_i$, but the rate is $2/(2i)=1/i$, which vanishes. Another sequence might use $n_i=2i+4$, $d_i=i$, and $k_i=6$. Then $G_i=4$, $D_i=6$, and the rate $6/(2i+4)$ still tends to zero. The finite logical capacity may differ, but bounded defect forces the same asymptotic conclusion.

## Two defects, one asymptotic density

For any positive block length, define the logical rate and normalized exact defect by

$$
R=\frac{k}{n},\qquad \delta=\frac{D}{n}.
$$

The finite-length capacity law immediately yields

$$
R\le \delta.
$$

Meanwhile,

$$
\delta=\frac{G}{n}+\frac{2}{n}.
$$

Thus the normalized exact defect differs from geometric defect density by precisely $2/n$. Along any family with $n_i\to\infty$,

$$
\delta_i-\frac{G_i}{n_i}=\frac{2}{n_i}\longrightarrow 0.
$$

At large scale, the geometric and exact viewpoints converge. At small scale, they should not be confused. For example, a perfectly balanced value $G=0$ does not force $k=0$; it permits as many as two logical qubits because $D=2$. The slogan “$n=2d$ leaves no room” is therefore false at finite length. The correct statement is that $n=2d$ leaves only a constant amount of room, and hence no positive density of logical information in a growing family.

This endpoint correction is more than a technical nuisance. It illustrates a recurring lesson in asymptotic science: two quantities can encode the same large-scale phenomenon while making different predictions for finite systems. Quantum devices are finite, so the $+2$ belongs in exact engineering estimates even when it disappears from asymptotic theory.

## Positive rate demands positive defect density

The capacity law can also be read backward. Suppose a code of positive length has rate at least $\varepsilon$:

$$
\varepsilon\le \frac{k}{n}.
$$

Since $k/n\le D/n$, it follows that

$$
\varepsilon\le \frac{D}{n}.
$$

This is a quantitative necessity theorem. Any attempt to maintain a positive logical rate must maintain at least as much normalized exact defect. For a growing family, the asymptotic agreement of defects means that a positive rate also requires positive geometric defect density in the limit, subject to the usual care about limit notions.

What the theorem does **not** provide is a reverse inequality. A positive defect density need not guarantee a positive rate. Defect is available capacity, and available capacity can go unused. Turning the upper bound into a two-sided law would require assumptions beyond the three numbers $n$, $k$, and $d$—perhaps geometric locality, expansion, local testability, or special features of a code construction.

This boundary between what parameters decide and what structure decides is scientifically productive. The arithmetic isolates the precise quantity any deeper theory must address. Rather than asking vaguely whether geometry supports information, one can ask when geometric hypotheses convert defect density into realized logical rate.

## Why geometry enters—and why arithmetic is not geometry

Local quantum codes are often drawn on lattices, cell complexes, surfaces, or tensor networks. Such pictures suggest relations among curvature, minimal cuts, entanglement, and coding distance. The defect $G=n-2d$ is an appealing bridge because it measures what remains after distance is charged against physical size.

But a global number cannot reconstruct a spatial arrangement. Two codes may share identical $[[n,k,d]]$ parameters and still have different stabilizer checks, syndrome graphs, decoder dynamics, and notions of locality. Parameter arithmetic constrains information capacity; it does not determine incidence geometry.

That observation points toward richer local quantities. One might assign defects to cuts in a tensor network and compare them with regional entropy. One might define a spatial defect density on a triangulated surface and study whether its variation, rather than its constant part, correlates with curvature. One might compare codes with matching parameters but inequivalent syndrome adjacency graphs. Each direction adds structure deliberately, rather than asking a single global inequality to carry geometric information it does not contain.

## A practical diagnostic

The defect law offers a quick screening test for proposed code families.

1. Record $n$, $k$, and $d$, and check $d>0$.
2. Verify the Singleton inequality $k+2(d-1)\le n$.
3. Compute $D=n+2-2d$ and $G=n-2d$.
4. Confirm the exact identities $0\le k\le D$ and $D=G+2$.
5. For $n>0$, compare the rate $k/n$ with the ceiling $D/n$.
6. Across a family, inspect whether $G$ is bounded, sublinear, or proportional to $n$.

If $G$ is bounded while $n$ grows, the diagnosis is immediate: logical rate and every protected entropy density bounded by $k/n$ must vanish. If a positive rate is claimed, then $D/n$ must remain at least that large. Any numerical proposal violating these conditions is inconsistent with the Singleton constraint.

## The remaining frontier

The exact law is a clean piece of parameter arithmetic:

$$
0\le k\le D=G+2.
$$

Its asymptotic message is equally clean: bounded geometric defect means zero logical rate and zero protected-entropy density. Positive rate requires positive exact-defect density.

The frontier begins where the inequality stops. Under what geometric conditions does defect become not only necessary but productive? Can cut-dependent defects explain regional entropies in tensor networks? Can spatial variation of a defect field detect curvature? Which syndrome geometries can coexist with identical global parameters?

These questions turn a modest rearrangement into a research program. The arithmetic does not solve geometry, decoding, or construction. Instead, it clears the ground. It identifies the budget, keeps the finite endpoint honest, and tells us exactly what extensive quantum information must cost.