# The Shape of Missing Information

## When an empty cell is not just an empty cell

A blank entry in a spreadsheet looks local: one measurement is absent from one row. Yet the difficulty of repairing it is rarely local. A hospital record may contain blood pressure and age in one table, age and medication in another, and medication and outcome in a third. Each fragment can look reasonable on its own. The real question is whether all fragments can be assembled into one coherent record.

That question has a shape. It is the same kind of shape mathematicians study when they ask whether maps drawn on overlapping pieces of a landscape can be joined into a map of the whole country. The relevant language is sheaf cohomology, but its central lesson is intuitive: **missing information lives not only in blank cells, but in failures of agreement around networks of overlap.**

This viewpoint replaces a single missing-rate statistic with a richer diagnosis. Two datasets can have the same number of observed and missing entries, and even the same number of overlap constraints, while one is perfectly repairable and the other carries a maximal obstruction. What matters is how observations overlap and how much independent corrective power the available local data provides.

## Local views and overlap alarms

Fix a field of numbers, such as the real numbers. We organize the data into three finite-dimensional vector spaces.

* $C^0$ is the space of local observations or local proposed values.
* $C^1$ is the space of discrepancies on pairwise overlaps.
* $C^2$ is the space of consistency checks on triple overlaps.

A linear map

$$
d^0:C^0\longrightarrow C^1
$$

records how changing local observations changes their pairwise discrepancies. A second linear map

$$
d^1:C^1\longrightarrow C^2
$$

checks whether a pattern of pairwise discrepancies is itself consistent around triples. The basic coherence rule is

$$
d^1d^0=0.
$$

In words, a discrepancy created by an actual change of local values automatically passes every higher consistency check. This is the algebraic version of a familiar fact: if three temperature sensors are shifted by definite amounts, the induced pairwise differences add consistently around the triangle.

Two spaces summarize the situation. The zeroth cohomology is

$$
H^0=\ker d^0.
$$

It consists of changes that create no overlap discrepancy at all—globally compatible local observations. The first cohomology is

$$
H^1=\ker d^1/\operatorname{im}d^0.
$$

The numerator contains discrepancy patterns that pass every local consistency test. The denominator contains patterns that can be explained away by changing local observations. Thus $H^1$ measures the residual ambiguity: locally consistent patterns that no available patch can remove.

A nonzero class in $H^1$ is a genuine obstruction. It says that local agreement tests do not guarantee a global repair.

## The information-loss equation

The central result is an exact accounting identity.

**Cohomological Information-Loss Theorem.** For every finite-dimensional data complex satisfying $d^1d^0=0$,

$$
\dim H^1+\operatorname{rank}d^0+\operatorname{rank}d^1=\dim C^1.
$$

Equivalently,

$$
\dim H^1=\dim C^1-\operatorname{rank}d^0-\operatorname{rank}d^1.
$$

The proof is a two-stage count. Rank–nullity gives

$$
\dim\ker d^1=\dim C^1-\operatorname{rank}d^1.
$$

Because $d^1d^0=0$, the image of $d^0$ lies inside this kernel. Quotienting by that image subtracts another $\operatorname{rank}d^0$ dimensions. What remains is exactly $\dim H^1$.

The formula separates two mechanisms. The rank of $d^1$ counts overlap patterns rejected by higher-order checks. The rank of $d^0$ counts accepted patterns that can be generated—and therefore removed—by adjusting local data. An obstruction survives only when it escapes both mechanisms.

This leads immediately to a diagnostic test.

**Rank-Deficit Criterion.** If

$$
\operatorname{rank}d^0+\operatorname{rank}d^1<\dim C^1,
$$

then $\dim H^1>0$, so some locally consistent discrepancy cannot be patched.

The criterion is useful because it needs only matrix ranks. It does not require enumerating every obstruction individually.

## Exactly when patching succeeds

There is also a clean all-or-nothing statement.

**Exact Patchability Theorem.** The obstruction space vanishes, $\dim H^1=0$, if and only if

$$
\ker d^1=\operatorname{im}d^0.
$$

So every discrepancy that passes the triple-overlap checks is patchable precisely when the complex is exact at $C^1$. One direction is immediate: if the two spaces coincide, their quotient is zero. Conversely, a zero-dimensional quotient of finite-dimensional spaces can occur only when the subspace being divided out is the whole numerator.

A particularly strong sufficient condition is surjectivity of $d^0$. If every possible pairwise discrepancy can be produced by adjusting local observations, then $\operatorname{im}d^0=C^1$. Coherence forces $d^1$ to vanish on all of $C^1$, and therefore $H^1=0$.

At the opposite extreme, suppose both maps are zero. Then no discrepancy can be removed and no discrepancy is rejected. Every vector in $C^1$ survives:

$$
\dim H^1=\dim C^1.
$$

These boundary cases are not curiosities. They disprove the idea that a scalar such as missing rate can, by itself, determine the amount of cohomological obstruction. Consider two systems with equal overlap-space dimension. In the first, both maps are zero, so the obstruction is maximal. In the second, $d^0$ is surjective, so the obstruction vanishes. Their coarse size statistics agree; their repairability is opposite.

## Why the overlap network matters

The local pieces also form a combinatorial object called a nerve. Make one vertex for each local chart or feature group. Connect two vertices when the corresponding charts overlap. Add a triangular face when three charts have a genuine common overlap, and continue similarly in higher dimensions.

Sometimes all higher overlaps are determined by pairwise ones. A nerve with this property is called **flag**: whenever a finite collection of vertices is pairwise connected, that collection spans a face.

**Flag-Nerve Reconstruction Theorem.** If the data nerve is flag, then it is recovered exactly from its pairwise-overlap graph by filling every clique with a simplex. Equivalently, every finite family of pairwise-compatible local charts forms a genuine higher-order overlap face.

The proof is built into the flag condition. Every face certainly has all its pairs connected. Conversely, flagness declares that every clique is already a face. The two collections therefore coincide.

This theorem marks the precise boundary of pairwise reasoning. In a flag nerve, the overlap graph contains the full combinatorial story. Without flagness, three charts may overlap pairwise while having no common triple intersection. A graph alone then invents a triangle that the data never possessed, and higher consistency checks can be misrepresented.

## A small numerical parable

Suppose $C^1$ has dimension $6$. In one system, $d^0$ has rank $2$ and $d^1$ has rank $3$. The information-loss theorem gives

$$
\dim H^1=6-2-3=1.
$$

One independent obstruction remains. In another system with the same six-dimensional overlap space, let $d^0$ have rank $4$ and $d^1$ have rank $2$. Then

$$
\dim H^1=6-4-2=0.
$$

The amount of overlap data is unchanged, but its algebraic organization has eliminated the hole.

The equation also suggests an algorithm. Encode the restriction and consistency operations as matrices $D_0$ and $D_1$. Check that $D_1D_0=0$. Compute their ranks by Gaussian elimination, and return

$$
h_1=\text{number of columns of }D_1-\operatorname{rank}D_0-\operatorname{rank}D_1.
$$

To inspect actual obstructions, compute a basis of $\ker D_1$ and reduce it modulo a basis of $\operatorname{im}D_0$.

## What this does—and does not—say about imputation

The topology gives a rigorous answer to a structural question: can locally consistent information be patched globally, and how many independent obstructions remain? It does not, by itself, choose the numerically best filled-in value. Nor does it make an estimator maximum-likelihood without a probability model.

This distinction matters. A proposed law such as

$$
\dim H^1\approx r^2n\log(1/r)
$$

for missing rate $r$ and feature count $n$ cannot be universal. The exact formula shows why: $\dim H^1$ depends on two ranks shaped by overlap incidence and restriction maps. A scalar $r$ does not determine either rank. Such an asymptotic law might emerge under a carefully specified random model, but it would be a theorem about that model, not about missingness in general.

Likewise, minimizing an overlap-residual norm is a natural least-squares procedure, but calling it maximum-likelihood requires assumptions such as Gaussian noise. Comparisons with mean imputation, nearest-neighbor methods, or chained equations require a shared data-generating process and explicit loss function.

The present framework therefore acts less like an automatic imputer and more like a structural scan. Before asking which value to insert, it asks whether the available pieces even determine a coherent answer.

## From exact holes to noisy near-holes

Real measurements rarely satisfy equations exactly. A matrix that should have a zero singular value may instead have a tiny one. This points toward a robust version of cohomology: count singular values below a tolerance, and distinguish structural holes from directions that are merely weakly constrained.

Random overlap networks offer another direction. As missingness increases, cycles can appear in the nerve; restriction maps may cancel some and preserve others. A realistic threshold theory must therefore track both combinatorial cycle creation and algebraic rank cancellation.

Finally, under an explicit Gaussian model, the spectrum of a sheaf Laplacian could separate irreducible ambiguity from numerical instability. Zero eigenvalues would record cohomology; small positive eigenvalues would warn that reconstruction is possible but fragile.

## The deeper lesson

A missing entry is visible. A missing relation is not. Cohomology reveals the latter by examining how local pieces meet, how discrepancies circulate, and which of them can be absorbed by legitimate corrections.

The decisive quantity is not simply how much data is absent. It is

$$
\dim C^1-\operatorname{rank}d^0-\operatorname{rank}d^1,
$$

the part of overlap space that is neither rejected by consistency nor explained by a patch. That is the topology of missing information: an exact measure of the holes left after every local test has passed and every available correction has been tried.
