library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Using VHDL 2008 for tb

entity FIFO_tb is 
  generic(
    kMemorySize : integer := 32;
    kAddressLength: integer := 5;
    kWordSize : integer := 8  
  );
end entity FIFO_tb;

architecture tb of FIFO_tb is 

  --Asynchronous reset
  signal aReset : std_logic;

  --Clock signals
  signal fFastClk, sSlowClk : std_logic := '1';

  --Data signals
  signal fDataIn, sDataOut : std_logic_vector(kWordSize-1 downto 0);

  --Flags
  signal fFull, fAlmostFull, sEmpty, sAlmostEmpty : std_logic;

  --Enable signals
  signal fWE, sRE : std_logic;

  --TB Specific signals
  signal Stop : boolean;

begin

  FIFO : entity work.FIFO(RTL)
    generic map (
      kMemorySize => 32,
      kAddressLength => 5,
      kWordSize => 8
    )
    port map (
      --Faster Clock Domain
      fFastClk => fFastClk,
      fDataIn  => fDataIn,
      fAlmostFull => fAlmostFull,
      fFull => fFull,
      fWE => fWE,

      --Slower Clock Domain
      sSlowClk => sSlowClk,
      sDataOut => sDataOut,
      sAlmostEmpty => sAlmostEmpty,
      sEmpty => sEmpty,
      sRE => sRE,

      --Reset
      aReset => aReset
    );

  
  --Generate fast clock
  fFastClk <= not fFastClk after 5 ns when not Stop;

  --Generate slow clock
  sSlowClk <= not sSlowClk after 5 ns when not Stop;

end architecture tb;