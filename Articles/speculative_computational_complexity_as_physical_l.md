# Fast Is Not Free: What Maxwell’s Demon Teaches Us About Computational Complexity

## A seductive shortcut

Imagine a tiny gatekeeper stationed between two chambers of gas. It watches molecules approach a trapdoor, admits fast molecules to one side and slow molecules to the other, and thereby creates a temperature difference without apparently doing work. The gatekeeper is Maxwell’s demon, the most famous troublemaker in thermodynamics. If the demon could repeat its sorting forever for free, it could turn random thermal motion into useful work and defeat the second law.

Now add a modern temptation. Many tasks are easy to check but appear hard to solve. Complexity theory calls the efficiently solvable decision problems $\mathsf{P}$ and the efficiently checkable ones $\mathsf{NP}$. What if $\mathsf{P}=\mathsf{NP}$? Would every clever search the demon needs suddenly become efficient? And if the demon became efficient, would thermodynamics collapse with complexity theory?

The answer developed here is sharp but perhaps unexpected. Under an extended Church–Turing assumption, an efficiently realizable physical solution to an $\mathsf{NP}$-hard problem would indeed force $\mathsf{P}=\mathsf{NP}$. Conversely, if $\mathsf{P}=\mathsf{NP}$, every $\mathsf{NP}$ decision task available to a demon becomes polynomial-time decidable. But this does **not** make the demon’s memory free to erase. At positive temperature, a one-bit erasure obeying the Jarzynski equality still requires strictly positive average work. Computational speed and thermodynamic cost measure different things.

That separation rescues the second law from a popular but faulty inference: fast is not the same as reversible, and efficient is not the same as free.

## Two currencies

Complexity theory measures how resources grow with input size. A polynomial-time algorithm uses at most a quantity such as $n^c$ steps for some fixed constant $c$. This can still be a large number, but its growth is controlled. The distinction between $\mathsf{P}$ and $\mathsf{NP}$ concerns whether efficiently checkable yes-certificates can always be replaced by efficient decision procedures.

Thermodynamics uses another currency. It asks how much energy is transferred, how much entropy is produced, and which microscopic distinctions a process destroys. A memory reset sends both logical inputs to the same output:

$$
0\longmapsto 0,\qquad 1\longmapsto 0.
$$

This map is not injective. Looking only at the output, one cannot reconstruct whether the input was $0$ or $1$. The operation has discarded information. Its logical irreversibility is a structural fact, independent of whether the reset takes one step, a million steps, or polynomially many steps.

Landauer’s principle attaches a physical price to that loss. Erasing one uniformly unknown bit at absolute temperature $T>0$ has the characteristic free-energy scale

$$
\Delta F=kT\ln 2,
$$

where $k>0$ is Boltzmann’s constant. At room temperature, about $300\,\mathrm{K}$, this is roughly $2.87\times 10^{-21}\,\mathrm{J}$ per bit. The number is tiny, but it is positive. Repeated over many bits or at enormous computational scales, it becomes a genuine accounting term.

## The physical-complexity model

To say exactly what follows from a hypothetical complexity collapse, consider a family of decision problems on some input space. Distinguish three classes:

1. $\mathcal{F}$, the problems physically realizable within a polynomial resource bound;
2. $\mathcal{P}$, the problems decidable by polynomial-time deterministic machines;
3. $\mathcal{N}$, the problems decidable with polynomially checkable nondeterministic evidence.

The model assumes three principles. First, the extended Church–Turing inclusion says

$$
\mathcal{F}\subseteq\mathcal{P}.
$$

Second, deterministic computation is a special case of nondeterministic computation, so

$$
\mathcal{P}\subseteq\mathcal{N}.
$$

Third, $\mathcal{P}$ is closed under polynomial-time many-one reductions: if one problem can be efficiently translated into another problem already in $\mathcal{P}$, then the first problem is also in $\mathcal{P}$.

A problem $D$ is $\mathcal{N}$-hard when every problem in $\mathcal{N}$ reduces efficiently to $D$. Think of $D$ as the decision task at the heart of a proposed demon: perhaps identifying which microscopic intervention yields a desired macroscopic effect.

These definitions give the **Physical Hardness Collapse Theorem**: if an $\mathcal{N}$-hard problem $D$ belongs to $\mathcal{F}$, then $\mathcal{N}\subseteq\mathcal{P}$, and hence $\mathcal{P}=\mathcal{N}$.

The proof is short enough to see in one glance. Physical polynomial realizability places $D$ in $\mathcal{P}$ by the extended Church–Turing inclusion. Every problem in $\mathcal{N}$ reduces to $D$ because $D$ is hard. Closure under reductions then puts every such problem in $\mathcal{P}$. The reverse inclusion was already assumed.

This theorem says something consequential about physical claims. A genuinely polynomial physical device for a complete search problem would not merely be a fast gadget; under the stated simulation thesis, it would settle the deterministic–nondeterministic class equality inside the model.

The converse transfer is equally direct. Under the collapse hypothesis $\mathcal{N}\subseteq\mathcal{P}$, any demon problem $D\in\mathcal{N}$ lies in $\mathcal{P}$. Thus a collapse makes the demon’s **decision problem** efficient. Nothing in this argument mentions heat, work, entropy, or erasure.

## Where the second law enters

For the thermodynamic half, take a finite set $\Omega$ of possible microscopic trajectories. Let $p(\omega)\geq 0$ be their probabilities, with

$$
\sum_{\omega\in\Omega}p(\omega)=1,
$$

and let $W(\omega)$ be the work performed along trajectory $\omega$. The expected work is

$$
\mathbb{E}[W]=\sum_{\omega\in\Omega}p(\omega)W(\omega).
$$

Set the inverse thermal energy to $\beta=(kT)^{-1}$ and the one-bit free-energy change to $\Delta F=kT\ln 2$. The finite Jarzynski condition is

$$
\sum_{\omega\in\Omega}p(\omega)e^{-\beta W(\omega)}=e^{-\beta\Delta F}.
$$

Because the exponential is convex, Jensen’s inequality gives

$$
e^{-\beta\mathbb{E}[W]}
\leq
\sum_{\omega\in\Omega}p(\omega)e^{-\beta W(\omega)}
=
e^{-\beta\Delta F}.
$$

Since $\beta>0$, the exponential is decreasing in the work variable after multiplication by $-\beta$, so

$$
\mathbb{E}[W]\geq\Delta F=kT\ln 2>0.
$$

This is the crucial thermodynamic conclusion. Individual trajectories may fluctuate below the bound, and some may even involve negative work, but the average cannot vanish under these assumptions.

We can now state the **Complexity–Thermodynamics Separation Theorem**. Suppose $\mathcal{N}\subseteq\mathcal{P}$ and a demon’s decision problem belongs to $\mathcal{N}$. Suppose further that its implementation resets a uniformly unknown bit, has a finite normalized trajectory distribution, operates with $k>0$ and $T>0$, and satisfies the Jarzynski condition with $\Delta F=kT\ln 2$. Then three conclusions hold simultaneously:

- the demon’s decision problem belongs to $\mathcal{P}$;
- the reset map is logically irreversible;
- the mean erasure work satisfies $\mathbb{E}[W]>0$.

The proof simply joins two independent arguments. Class inclusion gives efficient decidability. The two-to-one reset map gives non-injectivity. Jensen’s inequality gives positive average work. No premise allows “polynomial time” to be exchanged for “zero dissipation.”

A direct corollary is the **No-Zero-Work Demon Theorem**: under the same assumptions, it is impossible for the demon to be polynomial-time decidable while its mean erasure work is exactly zero. The contradiction is numerical, not rhetorical: zero cannot be at least the strictly positive number $kT\ln 2$.

## A room-temperature ledger

The scale becomes concrete with a simple calculation. For $N$ independently erased unbiased bits, the lower-bound scale adds:

$$
W_{\min}=NkT\ln 2.
$$

At $T=300\,\mathrm{K}$, one bit costs at least about $2.87\times10^{-21}\,\mathrm{J}$ on average under the model. A billion bits cost about $2.87\times10^{-12}\,\mathrm{J}$. A trillion bits cost about $2.87\times10^{-9}\,\mathrm{J}$. These energies are modest by everyday standards, yet none is zero.

The key point is not that all computers currently operate near this limit; they do not. Nor is it that every algorithm must erase one bit per step. Reversible circuits can retain history and, in principle, avoid dissipation during idealized logical evolution. The point is conditional and precise: when a process actually merges two possible logical states into one and later reuses the memory, that cleanup has an information-loss cost. A faster solution can reduce elapsed time without removing the distinction that the reset destroys.

## What the result does—and does not—say

The argument does not prove $\mathsf{P}\neq\mathsf{NP}$. It does not prove the extended Church–Turing thesis. It does not claim that every physical process is polynomially simulable, or that every decision algorithm necessarily erases a bit. It also does not deny fluctuations: the Jarzynski relation is an equality about an exponential average, from which the ordinary mean-work bound follows.

What it does establish is a disciplined bridge between two subjects. If a physically polynomial device solves a hard enough problem, complexity consequences follow by reduction. If a device erases information under finite positive-temperature Jarzynski dynamics, thermodynamic consequences follow by convexity. The bridges coexist, but they are not interchangeable.

This distinction matters beyond Maxwell’s demon. Machine-learning systems routinely separate inference from training, and both from data deletion. Cryptographic devices distinguish evaluating a function from clearing secret state. Reversible computing distinguishes carrying out a calculation from uncomputing its temporary workspace. In each case, computational difficulty describes the growth of an evaluation task, while thermodynamic cost depends on what information is ultimately discarded.

## The moral of the demon

Maxwell’s demon is valuable because it forces hidden bookkeeping into view. Its intelligence was never the whole story. The demon must remember observations, condition actions on them, and eventually restore its memory if the cycle is to repeat. That final restoration is where logical many-to-one behavior meets physical work.

A collapse of complexity classes would be an intellectual earthquake. It could transform which decisions are efficiently reachable. Yet even such an earthquake would not repeal the arithmetic of information loss. Under the finite positive-temperature assumptions above, a demon may become fast, but its erasure remains irreversible and its average work remains positive.

The universe may constrain computation in ways that complexity theory captures. Thermodynamics supplies another constraint. Their laws can speak to each other, but they keep separate accounts.