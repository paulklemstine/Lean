# The Vacuum Is Not a Fuel Tank

## A conservation-law guide to the limits of zero-point-energy harvesting

The phrase *empty space* is misleading. In quantum physics, a field in its lowest-energy state is not a perfectly still sea. Its observables fluctuate, and those fluctuations can have measurable consequences. They help shape atomic spectra, contribute to forces between carefully arranged surfaces, and set a persistent background against which quantum devices operate. It is therefore natural to ask a provocative engineering question: if the vacuum is restless, can a machine harvest that restlessness as useful power?

The answer depends on keeping two ideas separate. A fluctuation is not automatically a fuel supply, and a device that produces energy during one step is not automatically a self-sustaining generator. The decisive test is global accounting: after every input, output, and change in the apparatus has been counted, is there any net energy left over?

A compact mathematical model answers that question without committing to a particular cavity shape, switching protocol, detector, material, or interpretation of quantum theory. Its conclusion is sharp. A finite initial reserve may be discharged, and external work may pass through a machine and emerge as useful output. But vacuum fluctuations cannot become an unaccounted energy source in any process that obeys the stated energy balance. A cyclic machine returns no more useful energy than was supplied to it, while an unpowered machine beginning with no usable reserve produces nothing at all.

## Three ledgers and one rule

Imagine a device operating in discrete cycles numbered $t=0,1,2,\ldots$. At the beginning of cycle $t$, let $S_t$ be the usable energy stored in the apparatus and its local environment. This may include a charged battery, an excited atom, a compressed spring, a prepared field configuration, or any other resource that can later be converted into output. Let $I_t$ be the energy injected from outside during the cycle, and let $H_t$ be the useful energy harvested and delivered to a load.

All three quantities are nonnegative:

$$
S_t\ge 0,\qquad I_t\ge 0,\qquad H_t\ge 0.
$$

The central assumption is the per-cycle balance equation

$$
S_{t+1}+H_t=S_t+I_t.
$$

The left side records where energy ends up: some remains stored for the next cycle, and some leaves as useful output. The right side records where it came from: the previous reserve and the new external input. This simple equation does not deny quantum fluctuations. It says only that they do not open an invisible fourth account.

The model is deliberately broad. It does not describe microscopic dynamics, and it does not claim that every experimental quantity is easy to classify. Instead, it establishes what follows once a complete accounting boundary has been chosen. If moving a mirror costs work, that work belongs in $I_t$. If a detector was prepared in an excited state, that preparation contributes to the initial reserve or later input. If a switching circuit stores energy, its change belongs in $S_t$. The quality of the conclusion depends on the completeness of the ledger.

## The telescoping identity

Sum the balance equation over the first $N$ cycles. Intermediate stored-energy terms cancel: the reserve after one cycle appears once as an endpoint and once as the starting point of the next cycle. What remains is the **Finite-Horizon Conservation Theorem**:

$$
S_N+\sum_{t=0}^{N-1}H_t
=
S_0+\sum_{t=0}^{N-1}I_t.
$$

This is the whole argument in concentrated form. Initial storage plus all external input equals final storage plus all useful output. The proof is simply repeated substitution, or equivalently summing the one-cycle equations and canceling the intermediate terms.

Because $S_N\ge 0$, dropping the final reserve from the left side yields the **Absolute Extraction Bound**:

$$
\sum_{t=0}^{N-1}H_t
\le
S_0+\sum_{t=0}^{N-1}I_t.
$$

A machine may deliver more energy than was injected during the observed interval, but only by drawing down energy that was already present at the beginning. A dramatic pulse of output can therefore be real without being a new source of energy. The pulse may simply be a discharge.

To make that distinction explicit, define the net exported energy through $N$ cycles by

$$
E_{\mathrm{net}}(N)=\sum_{t=0}^{N-1}(H_t-I_t).
$$

Rearranging finite-horizon conservation gives an even more revealing identity:

$$
E_{\mathrm{net}}(N)=S_0-S_N.
$$

Since final storage is nonnegative, the **Net-Export Bound** follows:

$$
E_{\mathrm{net}}(N)\le S_0.
$$

No matter how intricate the protocol, cumulative output in excess of cumulative input cannot surpass the initial usable reserve.

## Why returning to the start matters

Many proposed energy-harvesting devices are meant to operate cyclically. After $N$ steps, their mechanical components, fields, detectors, and controls are supposed to return to the same usable-energy condition with which they began. Mathematically, that requirement is $S_N=S_0$.

Substituting it into the conservation identity gives the **Cyclic Equality Theorem**:

$$
\sum_{t=0}^{N-1}H_t
=
\sum_{t=0}^{N-1}I_t.
$$

Thus a lossless cyclic device can at best transform or redirect supplied energy; it cannot deliver a net surplus. Real devices dissipate energy, so practical output would ordinarily be smaller. The equality is therefore an ideal upper limit, not an efficiency forecast.

This resolves a common source of confusion in vacuum-energy discussions. A protocol may extract energy from a specially prepared field state, exploit a boundary change, or convert a detector’s excitation into electrical work. Yet if restoring the entire apparatus to its original state requires at least the extracted energy, the procedure is not a fuel-free engine. The reset is part of the cycle, not an optional footnote.

## The ground-state test

The cleanest thought experiment removes both possible conventional sources. Suppose the apparatus begins with no usable reserve, so $S_0=0$, and receives no external input, so $I_t=0$ for every cycle. Finite-horizon conservation becomes

$$
S_N+\sum_{t=0}^{N-1}H_t=0.
$$

Both terms on the left are nonnegative. Therefore each must be zero. This gives the **Ground-State No-Harvesting Theorem**:

$$
\sum_{t=0}^{N-1}H_t=0
$$

for every finite horizon $N$. Because every $H_t$ is itself nonnegative, the stronger pointwise result follows:

$$
H_t=0
$$

for every cycle $t$.

The statement is not that quantum fluctuations vanish. It is that, under complete conservation accounting, their presence does not permit useful output from an unpowered, zero-reserve apparatus. Noise in a meter, variance in an observable, and extractable thermodynamic work are different concepts.

## From finite reserves to vanishing long-run power

A finite battery can support a large output for a short time. What it cannot support is a positive net output rate forever. For $N>0$, define average net output per cycle by

$$
\overline P_N=\frac{E_{\mathrm{net}}(N)}{N}.
$$

The net-export bound immediately gives the **Average Net-Power Bound**:

$$
\overline P_N\le \frac{S_0}{N}.
$$

As the number of cycles grows, the right side approaches zero. More precisely, the **Long-Horizon Vanishing-Rate Theorem** says that for every target rate $\varepsilon>0$, there is a cycle count $N_0$ such that

$$
\frac{E_{\mathrm{net}}(N)}{N}<\varepsilon
$$

whenever $N\ge N_0$. One explicit choice is any positive integer satisfying $N_0>S_0/\varepsilon$. The initial reserve can create a temporary surplus, but when spread over a longer and longer run, its average contribution becomes negligible.

If each cycle lasts a fixed time $\Delta t>0$, the physical average power is $E_{\mathrm{net}}(N)/(N\Delta t)$, bounded by $S_0/(N\Delta t)$. The same conclusion holds: a finite reserve cannot sustain positive net power indefinitely.

## A numerical story

Consider a device beginning with $10$ joules of usable energy. During four cycles it receives inputs of $2$, $1$, $0$, and $3$ joules. Suppose it harvests $4$, $3$, $2$, and $1$ joules. The balance equation determines the stored-energy sequence:

$$
S_0=10,\quad S_1=8,\quad S_2=6,\quad S_3=4,\quad S_4=6.
$$

Total harvested energy is $10$ joules, total injected energy is $6$ joules, and net export is $4$ joules. That surplus did not come from nowhere: the stored reserve fell from $10$ to $6$ joules. Indeed,

$$
10-6=4.
$$

Had the device returned to $S_4=10$ joules, it could not have harvested $10$ joules from only $6$ joules of input. Another $4$ joules would have been needed to restore the reserve, making total input equal total output.

## What the bound does—and does not—say

This framework is an upper-bound argument, not a microscopic theory of the quantum vacuum. It does not calculate vacuum energy density, settle questions about gravity and the cosmological constant, or predict the output of a particular laboratory apparatus. It does not prohibit using non-vacuum resources hidden in an experiment: temperature differences, squeezed states, excited detectors, moving boundaries, chemical energy, feedback controllers, or measurement batteries can all power real effects.

What it does provide is a universal diagnostic. Draw a boundary around the device and everything needed to operate and reset it. Identify all usable energy initially inside. Record every energy transfer across the boundary. Then test the balance. If the proposal claims sustained positive net output while $S_t$ remains nonnegative and bounded, some input or resource has been omitted, or the conservation law has been abandoned.

That diagnostic connects vacuum-harvesting claims to ordinary engineering. A regenerative brake harvests energy, but from a moving vehicle. A heat engine harvests work, but from a temperature gradient while producing entropy. An antenna harvests electromagnetic energy, but from incoming radiation. In each case the word *harvest* describes conversion, not creation.

## The deeper lesson

Quantum theory teaches that emptiness has structure. Thermodynamics teaches that structure is not the same thing as a freely accessible reservoir. The bridge between those lessons is careful bookkeeping.

The most important equation is not mysterious:

$$
S_{t+1}+H_t=S_t+I_t.
$$

Yet its consequences reach every proposed cycle and every finite observation window. Total output is bounded by initial storage plus input. Net output is bounded by initial storage. A true cycle has no net surplus. A ground-state, unpowered device has no output. And any advantage furnished by a finite reserve fades to zero when measured as a long-run average rate.

The vacuum may fluctuate. A meter may click. Boundaries may move, forces may appear, and energy may be exchanged among fields and matter. But once the whole apparatus is included in the ledger, fluctuations do not become a bottomless fuel tank. The route from quantum restlessness to useful work still passes through the oldest rule in energy science: count everything.