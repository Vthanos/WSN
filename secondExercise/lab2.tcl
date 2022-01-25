# Εργαστήριο 3
# Προσομοίωση πρωτοκόλλου SMAC

# Καθορισμός παραμέτρων
set val(chan)           Channel/WirelessChannel    ;# τύπος καναλιού
set val(prop)           Propagation/TwoRayGround   ;# μοντέλο ράδιο-διάδοσης
set val(netif)          Phy/WirelessPhy            ;# τύπος διεπαφής δικτύου
set val(mac)            Mac/SMAC                   ;# πρωτόκολλο MAC
#set val(mac)            Mac/802_11                 ;# πρωτόκολλο MAC
set val(ifq)            Queue/DropTail/PriQueue    ;# τύπος ουράς
set val(ll)             LL                         ;# πρωτόκολλο επιπέδου ζεύξης
set val(ant)            Antenna/OmniAntenna        ;# μοντέλο κεραίας
set val(ifqlen)         50                         ;# μέγιστος αριθμός πακέτων στην ουρά
set val(nn)             5                          ;# αριθμός των κινητών κόμβων
set val(rp)             AODV                       ;# πρωτόκολλο δρομολόγησης

Mac/SMAC set syncFlag_ 1 ;# Ενεργοποιούμε τον μηχανισμό virtual clustering
Mac/SMAC set dutyCycle_ 50 ;# Δηλώνουμε το duty cycle % (εδώ 50 %)

# Ορισμός global μεταβλητών

set ns [new Simulator]
set tracefd [open simple.tr w]
$ns trace-all $tracefd
set nf [open out.nam w]
$ns namtrace-all-wireless $nf 1000 1000

proc finish {} {
    global ns nf tracefd
    $ns flush-trace
    close $nf
    close $tracefd
    exec nam out.nam -a &
    exit 0
}

# Ορισμός αντικειμένου τοπολογίας


set topo [new Topography]
$topo load_flatgrid 1000 1000

# Κατασκευή αντικειμένου God (General Operation Director)


create-god $val(nn)

# Ρύθμιση κόμβου


        $ns node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channel [new $val(chan)] \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace OFF \
			 -energyModel EnergyModel \
			 -idlePower 1.0 \
			 -rxPower 1.0 \
			 -txPower 1.0 \
			 -sleepPower 0.001 \
			 -transitionPower 0.2 \
			 -transitionTime 0.005 \
			 -initialEnergy 1000
			
			 
# Κατασκευή κινητών κόμβων

			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns node]	
		$node_($i) random-motion 0		;# απενεργοποίηση τυχαίας κίνησης
	}

# Ορισμός αρχικών συντεταγμένων για τους κινητούς κόμβους

$node_(0) set X_ 300.0
$node_(0) set Y_ 300.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 300.0
$node_(1) set Y_ 200.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 500.0
$node_(2) set Y_ 250.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 700.0
$node_(3) set Y_ 300.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 700.0
$node_(4) set Y_ 200.0
$node_(4) set Z_ 0.0



#Καθορισμός μεγέθους κόμβων

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns initial_node_pos $node_($i) 20
	}


# Ρύθμιση τηλεπικοινωνιακής κίνησης μεταξύ κόμβων
# CBR κίνηση μέσω UDP πακέτων

set udp0 [new Agent/UDP]
set sink0 [new Agent/Null]
$ns attach-agent $node_(0) $udp0
$ns attach-agent $node_(4) $sink0
$ns connect $udp0 $sink0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 40
$cbr0 set interval_ 5
$cbr0 attach-agent $udp0

set udp1 [new Agent/UDP]
set sink1 [new Agent/Null]
$ns attach-agent $node_(1) $udp1
$ns attach-agent $node_(3) $sink1
$ns connect $udp1 $sink1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 40
$cbr1 set interval_ 5
$cbr1 attach-agent $udp1

#Χρονοπρογραμματισμός των εφαρμογών

$ns at 5.0 "$cbr0 start"
$ns at 10.0 "$cbr1 start"

# Διαδικασία τερματισμού προσομοίωσης

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns at 150.0 "$node_($i) reset";
}
$ns at 150.0 "finish"

# Τρέξιμο προσομοίωσης
$ns run
