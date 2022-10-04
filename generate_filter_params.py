import math

FILT_NONE=0
FILT_LP=1
FILT_BP=2
FILT_LPBP=3
FILT_HP=4
FILT_NOTCH=5
FILT_HPBP=6
FILT_ALL=7


def calcResonanceLp(f):
        return 227.755 - 1.7635 * f - 0.0176385 * f * f + 0.00333484 * f * f * f

def calcResonanceHp(f):
        return 366.374 - 14.0052 * f + 0.603212 * f * f - 0.000880196 * f * f * f

def calc_filter(f_type,f_freq,f_res):
        # Filter off? Then reset all coefficients
        if f_type == FILT_NONE:
                f_ampl = F_ZERO
                d1 = d2 = g1 = g2 = F_ZERO
                return
        
        # Calculate resonance frequency
        if f_type == FILT_LP or f_type == FILT_LPBP:
                fr = calcResonanceLp(f_freq)
        else:
                fr = calcResonanceHp(f_freq)
                
        # Limit to <1/2 sample frequency, avoid div by 0 in case FILT_NOTCH below
        arg = fr / float(44100/2)
        if arg > 0.99:
                arg = 0.99
        if arg < 0.01:
                arg = 0.01

        # Calculate poles (resonance frequency and resonance)
        # The (complex) poles are at
        #  zp_1/2 = (-g1 +/- sqrt(g1^2 - 4*g2)) / 2
        g2 = 0.55 + 1.2 * arg * arg - 1.2 * arg + float(f_res) * 0.0133333333
        g1 = -2.0 * math.sqrt(g2) * math.cos(math.pi * arg)

        # Increase resonance if LP/HP combined with BP
        if f_type == FILT_LPBP or f_type == FILT_HPBP:
                g2 += 0.1

        # Stabilize filter
        if math.fabs(g1) >= g2 + 1.0:
                if g1 > 0.0:
                        g1 = g2 + 0.99
                else:
                        g1 = -(g2 + 0.99)

        # Calculate roots (filter characteristic) and input attenuation
        # The (complex) roots are at
        #   z0_1/2 = (-d1 +/- sqrt(d1^2 - 4*d2)) / 2
        
        if f_type == FILT_LPBP or f_type == FILT_LP:
                d1 = 2.0 
                d2 = 1.0
                f_ampl = 0.25 * (1.0 + g1 + g2)
        elif f_type == FILT_HPBP or f_type == FILT_HP:
                d1 = -2.0 
                d2 = 1.0
                f_ampl = 0.25 * (1.0 - g1 + g2)
        elif f_type == FILT_BP:
                d1 = 0.0 
                d2 = -1.0
                c = math.sqrt(g2*g2 + 2.0*g2 - g1*g1 + 1.0)
                f_ampl = 0.25 * (-2.0*g2*g2 - (4.0+2.0*c)*g2 - 2.0*c + (c+2.0)*g1*g1 - 2.0) / (-g2*g2 - (c+2.0)*g2 - c + g1*g1 - 1.0)
        elif f_type == FILT_NOTCH:
                d1 = -2.0 * math.cos(math.pi * arg) 
                d2 = 1.0
                if arg >= 0.5:
                        f_ampl = 0.5 * (1.0 + g1 + g2) / (1.0 - math.cos(math.pi * arg))
                else:
                        f_ampl = 0.5 * (1.0 - g1 + g2) / (1.0 + math.cos(math.pi * arg))
                        
                # The following is pure guesswork...
        elif f_type == FILT_ALL:
                d1 = -4.0 * math.cos(math.pi * arg) 
                d2 = 4.0
                if arg >= 0.5:
                        f_ampl = (1.0 - g1 + g2) / (5.0 + 4.0 * math.cos(math.pi * arg))
                else:
                        f_ampl = (1.0 + g1 + g2) / (5.0 - 4.0 * math.cos(math.pi * arg))

        return [f_ampl,d1,d2,g1,g2]
                        
# ; fr: 209.745911
# ; arg: 0.010000
# ; f_type: 1
# ; f_freq: 18
# ; f_res: 15
# ; f_ampl: 0.005172
# ; d1: 2.000000
# ; d2: 1.000000
# ; g1: -1.717430
# ; g2: 0.738120
# ; ob.freq: 44100

# calc_filter:
#  fr: 227.755005
#  arg: 0.010329
#  f_type: 1
#  f_freq: 0
#  f_res: 0
#  f_ampl: 0.017975
#  d1: 2.000000
#  d2: 1.000000
#  g1: -1.465834
#  g2: 0.537733
#  ob.freq: 44100


maxxx=-10000
for type in [FILT_LP,FILT_BP,FILT_LPBP,FILT_HP,FILT_NOTCH,FILT_HPBP,FILT_ALL]:
        print(";;;;;; Type=%d" % (type))                        
        for res in range(0,16):
                print(";;; Type=%d, resonance %d" % (type,res))                        
                for freq in range(0,256):
                        result = calc_filter(type,freq,res)
                        for r in result:
                                maxxx = max(maxxx,r)
                        [amp,d1,d2,g1,g2] = result
                        m=1<<13
                        print("  dc.w %d,%d,%d,%d,%d" % (amp*m,d1*m,d2*m,g1*m,g2*m))
                        #print("  dc.l %f,%f,%f,%f,%f" % (amp*m,d1*m,d2*m,g1*m,g2*m))
#print("Max " + str(maxxx))
