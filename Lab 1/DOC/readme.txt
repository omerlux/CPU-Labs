���� �� ����� �� ���� �������� ���� �-VHDL �������� ������� ����. 
��� ������ ��� ��� �� ��� ���������� (�� ������ ��������� 1 ������� ��� ����) :

1. MUX2 - ���������� �� ���� MUX2-1 �������� ����� �� ��� ���.
1. FA - ���������� �� ���� Full Adder - ���� ���� ����� (��� ������ Carry-in ������ Carry-out).
1. Selector - ���������� �� ���� ����� �� ������ ������ �� ������ (���� ��� �-shifter ��-Adder_Substructor) ��� ��� �-SEL.
2. Yblock - ���������� �� ���� ����� N ����� MUX2 ����� ������ ���� �-shifter (�� ��� �� ���� ����� �shifter ������ �Yblock).
2. Adder_Substructor - ���������� �� ���� ����-���� (���� �� �� ��� Carry-in) ����� ����� �-2 �� ��� �������� ����� N �����. 
���� �-N ����� FA. ������ ��� ����� ����� N+1 (�� ����� ����� �-2).
3. shifter - ���������� �� ���� barrel shifter 8-Bit ����� ���� ����� �� 0-7 ����� ���� ������ X (��� ����� 0-2 �� ��� ������ Y). 
����� ���� ������ ����� Yblock ���� ������ ���� 0 �� 1 �����, ���� 0 �� 2 �����, ������� 0 �� 4 �����, ����� ������ 0-2 �� ��� ������ Y.
4. top - ���������� ����� ������� �� ������ - ����� �� �� ��� ������� ������ ������� ���� ���� ����� �� ����� ������ �� ����� ������ X,Y ����� N �����.
����� ����� shifter, ���� Selector ����� Adder_Substructor.
 ** aux_package - ������ �-components �� ������ ���� �� ������� �� �entities ������ ������������ ������� ����.

