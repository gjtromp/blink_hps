set_time_format -unit ns -decimal_places 2

# Global 50MHZ input clock
create_clock -name {clk50m} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk50m}]


