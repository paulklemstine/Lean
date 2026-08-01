# The Price of Forgetting: Energy, Information, and the Limits of Vacuum Harvesting

Imagine a device advertised as an engine for empty space. It sits inside a sealed laboratory, waits for quantum fields to fluctuate, sorts favorable fluctuations from unfavorable ones, and sends useful power to a load. No fuel enters. After each cycle, the device returns to its original condition. Could it steadily turn the restless vacuum into electricity?

The seductive part of this picture is real: quantum fields do fluctuate, even in their lowest-energy state. The mistake is to identify fluctuation with freely available fuel. An engine does not merely encounter microscopic events. It must distinguish outcomes, retain records, make choices, and reset itself for the next cycle. Those informational operations belong in the energy ledger.

A clean finite-state model makes this point exact. It does not depend on the detailed engineering of a proposed vacuum device. Instead, it combines two principles: conservation of energy and the thermodynamic cost of destroying information. The result is a sharp budget inequality and a rigidity theorem. Together they say that a closed, cyclic, positive-temperature process cannot both reset information and export energy. If it receives no external energy and returns its stored reserve to its starting value, every computational step must be reversible and every harvested output must vanish.

## A cycle has two ledgers

Consider a process running at discrete times $t=0,1,2,\ldots$. At step $t$, let $S_t$ be its stored energy, $I_t$ the energy injected from outside, and $H_t$ the useful energy exported to a load. All three are nonnegative where appropriate: $S_t\ge 0$, $I_t\ge 0$, and $H_t\ge 0$.

The device also performs a finite computation. Its possible internal states before the step form a nonempty finite set $A_t$, and the step applies a function

$$
f_t:A_t\to B_t.
$$

Only some outputs in $B_t$ may actually occur. Write $R_t=|f_t(A_t)|$ for the number of reached outputs and $M_t=|A_t|$ for the number of possible inputs. When several inputs are mapped to one output, the computation forgets which input occurred. The lost capacity, measured in bits, is

$$
e_t=\log_2 M_t-\log_2 R_t=\log_2\!\left(\frac{M_t}{R_t}\right).
$$

Because a function cannot have more distinct images than inputs, $1\le R_t\le M_t$, so $e_t\ge 0$.

At temperature $T$ with Boltzmann constant $k_B$, Landauer's principle assigns an energy cost of at least $k_BT\ln 2$ to each erased bit. In the idealized accounting model, the informational debit at step $t$ is therefore

$$
L_t=e_t k_BT\ln 2.
$$

This is not a mysterious extra tax. It is ordinary energy that must end up somewhere—typically as heat—when distinctions are irreversibly discarded.

## The local balance law

The entire argument begins with one transparent equation. At every step,

$$
S_{t+1}+H_t+L_t=S_t+I_t.
$$

The right side is what the process has available: its previous reserve plus external input. The left side records where that energy goes: the new reserve, useful output, and information-erasure dissipation.

Now add this equation from $t=0$ through $t=N-1$. Every intermediate stored-energy term cancels. This telescoping produces the **Finite-Horizon Information–Energy Conservation Theorem**:

$$
S_N+\sum_{t=0}^{N-1}H_t+\sum_{t=0}^{N-1}L_t
=S_0+\sum_{t=0}^{N-1}I_t.
$$

This identity is the backbone of the story. It says that computational thermodynamics is not a metaphor layered over energy conservation. It is part of the same finite budget.

Since $S_N\ge 0$, dropping the terminal reserve gives the **Harvesting Budget Bound**:

$$
\sum_{t=0}^{N-1}H_t+\sum_{t=0}^{N-1}L_t
\le S_0+\sum_{t=0}^{N-1}I_t.
$$

Useful output and irreversible information processing compete for the same resources. A controller cannot be treated as an invisible spectator whose memory is reset for free.

## Counting states gives a device-independent bound

Sometimes the exact number $R_t$ of reached outputs is hard to know, while the size of the declared output space $|B_t|$ is easy to bound. Since $f_t(A_t)\subseteq B_t$,

$$
R_t\le |B_t|.
$$

The logarithm is increasing, so the actual erased capacity obeys the **Finite-State Compression Lemma**:

$$
e_t\ge \log_2|A_t|-\log_2|B_t|.
$$

Multiplying by the nonnegative bit price $p=k_BT\ln 2$ and summing yields the central **Information-Adjusted Extraction Bound**:

$$
\sum_{t=0}^{N-1}H_t+
\sum_{t=0}^{N-1}
\bigl(\log_2|A_t|-\log_2|B_t|\bigr)p
\le S_0+\sum_{t=0}^{N-1}I_t.
$$

This form is useful precisely because it asks for so little microscopic detail. If a step compresses $2^{20}$ possible states into at most $2^{12}$ outputs, then it loses at least $8$ bits of capacity. At room temperature, that step carries an ideal minimum debit of $8k_BT\ln 2$. Real hardware will usually dissipate more, never less under the model.

The cardinality term can be negative if the codomain is larger than the input set, but then it is merely a weak lower bound; the actual loss $e_t$ remains nonnegative because the image never exceeds the input set. The strongest estimate uses the reached image itself.

## When is forgetting exactly zero?

A second elementary fact has powerful consequences. The erased capacity satisfies $e_t=0$ exactly when $R_t=M_t$. For a function on a finite input set, this happens exactly when distinct inputs always produce distinct outputs. Thus the **Reversibility Criterion** states:

> A finite computation has zero erased capacity if and only if it is injective.

An injective step preserves enough information to reconstruct its input from its output. It may transform information, move it, or encode it in a larger space, but it does not merge alternatives. Logical reversibility is therefore not an aesthetic preference; it is the unique way, in this finite model, to make the Landauer debit vanish at positive temperature.

## The closed-cycle no-harvesting theorem

Now impose the conditions that make a purported vacuum engine most interesting. Let the process receive no external energy before time $N$, so $I_t=0$ for every $t<N$. Require it to complete a cycle in stored energy, so $S_N=S_0$. Assume $k_B>0$ and $T>0$.

The telescoping identity becomes

$$
\sum_{t=0}^{N-1}H_t+\sum_{t=0}^{N-1}L_t=0.
$$

Every term in both sums is nonnegative. A finite sum of nonnegative numbers can equal zero only when every term equals zero. Consequently $H_t=0$ and $L_t=0$ for every $t<N$. Positive $k_B$, positive $T$, and positive $\ln 2$ then force $e_t=0$. By the reversibility criterion, every $f_t$ is injective.

This is the **Unpowered Cyclic Rigidity Theorem**:

> At positive temperature, a finite-state process that receives no external energy and returns to its initial stored energy exports no useful energy at any step, and every computation it performs is logically reversible.

The theorem is stronger than an average statement. It does not merely say that net harvested energy is zero; nonnegativity rules out a positive harvest at even one step. Nor does it merely cap total erasure; every individual step must preserve distinctions.

## A numerical thought experiment

Suppose a controller has $1024$ possible premeasurement records but resets them into $16$ reachable states. It erases

$$
\log_2(1024)-\log_2(16)=10-4=6
$$

bits. At $T=300\,\mathrm{K}$, using $k_B\approx1.380649\times10^{-23}\,\mathrm{J/K}$, the ideal Landauer debit is

$$
6k_BT\ln 2\approx1.72\times10^{-20}\,\mathrm{J}.
$$

That is tiny for one cycle, but a device operating at $10^{15}$ such resets per second would face an idealized informational power debit near $1.72\times10^{-5}\,\mathrm{W}$, before ordinary losses. The arithmetic scales linearly with erased bits and cycle rate.

The point is not that this particular number defeats every proposed apparatus. The point is structural: any honest claim must identify the external input, depletion of stored reserve, entropy export, or preserved information that pays the bill. Calling the source “vacuum fluctuations” does not remove those columns from the ledger.

The same lesson appears in familiar technology. A phone can run briefly without a charger because its battery falls to a lower-energy state. A refrigerator can move heat against its spontaneous direction because electricity enters through the wall. A measurement controller can postpone memory reset by writing outcomes onto fresh storage. None is a perpetual engine: each draws down a resource or exports a burden. The finite-state equations put these familiar facts and exotic vacuum proposals under one rule.

## What the bound does—and does not—say

This framework does not deny quantum fluctuations, forbid temporary exchanges with a field, or claim that every microscopic interaction is a digital computer. It also does not rely on assigning equal probabilities to controller states: the logarithmic quantity measures available finite-state capacity, so the conclusion is a worst-case structural statement rather than a prediction of a particular outcome frequency. It offers a general accounting theorem for cyclic finite-state controllers whose irreversible distinctions are charged at the Landauer rate. A device may export energy by consuming an initial battery, accepting external work, ending in a lower-energy state, or discharging information into an environment. What it cannot do is erase those costs from the description while retaining the output.

The model also reveals a constructive direction. Reversible computing can reduce the informational debit by embedding a many-to-one operation into a larger, injective transformation that retains auxiliary records. But the records must eventually be managed. If they are erased to restore a finite controller to its original state, the cost returns; if they accumulate, the overall process is not cyclic in its full state.

That is why the boundary between physics and information matters. A demon, sensor, feedback loop, or vacuum-harvesting controller is not outside thermodynamics. Its decisions are physical transitions among distinguishable states. Once those states enter the balance sheet, the apparent loophole closes with a simple equation: what leaves as useful work, what leaves as heat, and what remains stored cannot exceed what was present initially plus what entered from outside.

Empty space may be active, subtle, and quantum mechanical. But an engine that promises something for nothing must still balance both of its ledgers—and, in the end, they are one ledger.