library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO is 
  generic(
    kMemorySize : integer := 32;
    kAddressLength: integer := 5;
    kWordSize : integer := 8
  );
  port(
    --Faster Clock Domain
    fFastClk : in std_logic;
    fDataIn : in std_logic_vector(kWordSize-1 downto 0);
    fAlmostFull : out std_logic; --should signal fast clk to slow writes 
    fFull : out std_logic;
    fWE : in std_logic;
    aReset : in std_logic; --asynchronous reset signal to flush FIFO

    --Slower Clock Domain
    sSlowClk : in std_logic;
    sDataOut : out std_logic_vector(kWordSize-1 downto 0);
    sAlmostEmpty : out std_logic;
    sEmpty : out std_logic;
    sRE : in std_logic
  );
end entity FIFO;

architecture RTL of FIFO is
  type t_InputBuffer is array (positive range<>) of std_logic_vector;

  signal fInputBuffer : t_InputBuffer (kMemorySize-1 downto 0);
  signal fInputBufferWritePtr : std_logic_vector (kAddressLength-1 downto 0);

  signal sBufferReadPtr : std_logic_vector (kAddressLength-1 downto 0);
begin 
  
  --full and empty flags should be combinatorial logic not sequential

  --implement ring buffer later just stop when its full
  fFull <= '1' when fInputBufferWritePtr = (others => '1') else 
           '0';
  
  --once read ptr catches up to write ptr we can assume the fifo is empty
  sEmpty <= '1' when fInputBufferWritePtr = sBufferReadPtr else 
            '0';


  FlushFIFO: process(aReset) begin 
    if rising_edge(aReset) then 
      fInputBuffer <= (others => (others => '0'));
      fInputBufferWritePtr <= (others => '0');

      
    end if;
  end process FlushFIFO;

  FastClkWE: process(fFastClk) begin --Fast Clk is writing to FIFO
    if rising_edge(fFastClk) then 

      if fWE and not fFull then --write enabled and not full
        fInputBuffer(fInputBufferWritePtr) <= fDataIn;
        fInputBufferWritePtr <= std_logic_vector(to_unsigned(fInputBufferWritePtr) + 1);
      end if; --will create a latch if default case is not created

    end if;
  end process FastClkWE;

  SlowClkRE: process (sSlowClk) begin 
    if rising_edge(sSlowClk) then 
      if sRE and not sEmpty then 
        sDataOut <= fInputBuffer(sBufferReadPtr);
        sBufferReadPtr <= std_logic_vector(to_unsigned(sBufferReadPtr) + 1);
      end if;
    end if;
  end process SlowClkRE;

end architecture RTL;