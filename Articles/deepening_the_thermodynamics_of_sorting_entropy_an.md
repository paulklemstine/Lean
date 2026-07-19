# The Thermodynamics of Sorting: Where the Missing Order Goes

## A familiar task with a hidden question

Imagine a shuffled deck laid face up on a table. You sort it by rank, and the disorder vanishes. Before sorting, the deck might have been in any of many arrangements; afterward, it has one prescribed order. It is tempting to tell a simple thermodynamic story: sorting destroys uncertainty, every comparison removes a little of it, and the machine must pay for that destruction as heat.

That story contains an important truth, but it also hides a trap. A comparison is not automatically an erasure. A sorting device can preserve enough information to run backward, reconstructing the exact shuffled input. If it does, the visible cards are sorted, yet no logical information has disappeared. The thermodynamic bill is attached not to the fact that comparisons occurred, but to information that is eventually discarded.

The cleanest way to see this is to separate three questions:

1. How many binary comparisons are needed to distinguish all possible input orders?
2. How much information does an irreversible sorting map erase?
3. How much hidden history must a reversible sorter retain?

Remarkably, the same number controls all three answers: the factorial $n!$.

## Why factorials appear

Take $n$ distinct items. Their possible input orders are the permutations of those items, and there are

$$
n!=1\cdot 2\cdot 3\cdots n
$$

such permutations. For $n=5$, there are $120$; for $n=10$, there are $3{,}628{,}800$; for $n=20$, the number already exceeds $2.4\times 10^{18}$.

A comparison has two outcomes, so a sequence of comparisons traces a path through a binary decision tree. Each leaf is a possible terminal transcript. A tree of height $h$ has at most $2^h$ leaves. If the tree is to distinguish every possible ordering, it needs at least $n!$ leaves. Therefore

$$
n!\leq 2^h,
$$

and hence

$$
h\geq \left\lceil\log_2(n!)\right\rceil.
$$

This is the **comparison-tree lower bound**: any binary comparison scheme with enough terminal outcomes to distinguish all orderings has worst-case depth at least $\lceil\log_2(n!)\rceil$.

For ten distinct items, $\log_2(10!)\approx 21.79$, so at least $22$ comparisons are needed in the worst case. For one hundred items, the lower bound is $525$. The familiar $n\log n$ scale of efficient sorting is already visible here, because $\log(n!)$ grows like $n\log n-n$.

This is a statement about discrimination. It says that a comparison tree needs enough binary transcript capacity. It does not yet say that the computer has erased one bit per comparison, nor that each comparison has dissipated a fixed amount of heat.

## Measuring logical erasure

To talk precisely about information loss, consider any function $f$ from a finite input set $X$ to a finite output set. Let $f(X)$ denote the set of outputs that actually occur. Define the information erased by $f$ as

$$
I(f)=\log_2|X|-\log_2|f(X)|.
$$

This quantity measures the shrinkage of the state space in base-two units. If $f$ is a bijection, then $|f(X)|=|X|$ and $I(f)=0$. If every input is sent to one output, then $|f(X)|=1$ and $I(f)=\log_2|X|$.

Now model visible sorting at the level of orderings. The input set consists of all $n!$ permutations. Once item identities are ignored in the visible order and only the canonical sorted result is reported, every permutation has the same visible output. The image has one element. The **Sorting Erasure Theorem** therefore states:

> For $n$ distinct items, the visible sorting map erases exactly $\log_2(n!)$ bits of information.

Indeed,

$$
I_{\mathrm{sort}}=\log_2(n!)-\log_2(1)=\log_2(n!).
$$

The edge case $n=0$ causes no difficulty: $0!=1$, so the empty input has one ordering and the erased information is $0$.

## From erased bits to Landauer work

Landauer's principle associates a minimum thermodynamic scale with logically irreversible erasure. At temperature $T$, write $kT$ for Boltzmann's constant times temperature. Erasing one bit has the scale $kT\ln 2$. Thus erasing $b$ bits has the Landauer scale

$$
W=kT\ln 2\, b.
$$

Substituting $b=\log_2(n!)$ makes the change of logarithm base cancel:

$$
W_{\mathrm{sort}}=kT\ln 2\,\log_2(n!)=kT\ln(n!).
$$

This is the **Exact Landauer Scale Theorem** for the irreversible visible sorting map. It is a logical lower-bound scale, not a prediction that a real laptop sorting an array will operate at that limit. Actual devices have friction, electrical resistance, clocking overhead, error margins, memory traffic, and many other sources of dissipation. The theorem identifies the information-theoretic contribution associated with deliberately forgetting which permutation arrived.

At room temperature, approximately $T=300\,\mathrm{K}$, $kT$ is about $4.14\times10^{-21}\,\mathrm{J}$. Sorting ten distinct items irreversibly has scale

$$
kT\ln(10!)\approx 6.25\times10^{-20}\,\mathrm{J}.
$$

The number is tiny for a single operation, but the principle matters whenever computation is repeated on enormous scales or pushed toward fundamental energy limits.

## Reversible sorting changes the answer

Now imagine a sorter with two output trays. The first displays the sorted result. The second quietly stores a complete description of the original permutation. From the pair of outputs, one can reconstruct the input exactly. The overall transformation is one-to-one and onto its state space: it is reversible.

The **Reversible Sorting Theorem** states:

> There exists a reversible realization of sorting that produces the same visible sorted output while retaining the complete input permutation as history. As an overall transformation, it erases zero information and has zero Landauer gap.

The reason is simple. A reversible map preserves the number of states. Its image is the whole output state space, so

$$
I=\log_2|X|-\log_2|X|=0.
$$

The sorted component alone no longer tells us the input, but the sorted component together with history does. Information has moved; it has not vanished.

Could the history be much smaller than the set of all permutations? Not in this product-form model. If the visible result has only one possible value and the total map is reversible, two different input permutations must produce different histories. Therefore the history register needs at least $n!$ states. This gives the **History-Space Lower Bound**:

> Every reversible realization whose output consists of one visible sorted state and an auxiliary history state requires at least $n!$ possible history values.

Equivalently, the history needs capacity of at least $\log_2(n!)$ bits. Retaining the entire permutation achieves exactly $n!$ possible histories, so the bound is sharp at the level of state counting.

This exposes a conservation-like principle. Irreversible sorting may collapse $n!$ possibilities into one and incur the logical erasure scale $kT\ln(n!)$. Reversible sorting avoids that collapse only by carrying forward a history space large enough to distinguish those same $n!$ possibilities.

## Why comparisons are not units of heat

Suppose someone proposes a universal rule: every comparison costs one bit of thermodynamic erasure. A simple construction disproves the idea at the logical level.

Start with any binary comparison tree. Add a redundant comparison above it, and send both outcomes into identical copies of the original tree. Repeat this $r$ times. The resulting padded tree performs $r$ extra comparisons on every path. Its height increases from $h$ to $h+r$, and it still has enough leaves to handle every ordering the original tree could handle.

Yet its visible input-output function is unchanged. The same permutations still collapse to the same sorted output, so the erased information remains $\log_2(n!)$ and the Landauer scale remains $kT\ln(n!)$.

This is the **Padding Invariance Theorem**:

> Redundant binary levels can increase worst-case comparison depth by any prescribed amount without changing the logical information erased by sorting or its Landauer scale.

The theorem draws a bright line between an algorithm's transcript length and a function's many-to-one character. Comparisons can be carried out reversibly, their outcomes can be retained, and temporary data can sometimes be uncomputed. Thermodynamic cost appears when records are reset or otherwise merged without preserving distinctions. To translate a comparison count into heat, one needs a physical model specifying which registers are reset, how reliably they operate, and what information is released to the environment.

## One factorial, three roles

The central synthesis can now be stated in one sentence. For sorting $n$ distinct items:

$$
\left\lceil\log_2(n!)\right\rceil
$$

is a lower bound on worst-case binary comparison depth;

$$
\log_2(n!)
$$

is the information erased by the irreversible visible sorting map; and

$$
n!
$$

is a lower bound on the number of history states in any product-form reversible realization.

These are related, but they are not interchangeable. The comparison bound concerns how many binary distinctions a decision process can make. The erasure result concerns how many input states a visible function merges. The history bound concerns how many distinctions must survive if the whole process is to remain reversible.

That separation matters beyond sorting. Data compression, garbage collection, cryptographic circuits, database queries, and machine-learning pipelines all create intermediate records and often discard them. The energetic question is not merely how many operations occurred. It is which distinctions the final physical process preserved, exported, or erased.

## The real lesson

Sorting looks like order emerging from disorder, but the mathematics tells a subtler story. The apparent disappearance of disorder is not enough to establish erasure. If a machine keeps the shuffled order in a history register, the computation can be reversed and the logical Landauer gap is zero. If it throws that record away, then $\log_2(n!)$ bits have genuinely been merged, with thermodynamic scale $kT\ln(n!)$.

So where does the missing order go? Either it remains somewhere—in history, in an environment, or in correlations—or it is erased. Factorials count the possibilities. Decision trees tell us how many binary questions are needed to distinguish them. Reversible histories tell us how much memory must carry them forward. Landauer's principle tells us why finally forgetting them can never be thermodynamically free.
