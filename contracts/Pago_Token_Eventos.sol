// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./ERC20_Evento.sol";

contract Restaurant_payment {



//================================== INITIAL STATEMENTS =========================================

    ERC20Basic private token;
    address public owner;

       constructor() {
        token = new ERC20Basic(10000);
        owner = msg.sender;
    }


struct cliente{
        string Nombre_cliente;
        string Apellido_cliente;
        string Mail_cliente;
        uint tokens_comprados;
        string[] attracciones_disfrutadas;
    }

    mapping(address => cliente) public Clientes;

function registro_cliente(string memory _nom, string memory _app, string memory _mail) public {
    Clientes[msg.sender].Nombre_cliente   = _nom;
    Clientes[msg.sender].Apellido_cliente = _app;
    Clientes[msg.sender].Mail_cliente     = _mail;
}




//================================== TOKENS =========================================

//@notice: sets the price of a token
//@params: _numTokens is the amount of tokens you want to set a price to
function PrecioTokens(uint _numTokens) internal pure returns (uint){
    return _numTokens*(18000000000000 wei); 
}

//@notice: restricted function to owner
modifier Unicamente(address _direccion){
    require(_direccion == owner, "No tienes permisos para ejecutar esta funcion");
    _;
}


//@notice: increases the amount of tokens
//@params: _numTokens is the amount of tokens to increase
function GeneraTokens(uint _numTokens) public Unicamente(msg.sender){
    token.increaseTotalSuply(_numTokens);
}




//@notice: Buy tokens
//@params: _numTokens is the amount you want to buy 
function ComprarTokens(uint _numTokens) public payable{
    uint coste = PrecioTokens(_numTokens);
    require(msg.value >= coste, "Compra con menos Tokens o paga con mas ethers");
    uint returnValue = msg.value - coste;
    payable(msg.sender).transfer(returnValue);   
    uint Balance = balanceOf();
    require(_numTokens <= Balance, "Compra un numero menor de Tokens");
    token.transfer(msg.sender, _numTokens);
    Clientes[msg.sender].tokens_comprados += _numTokens;
}

//@notice: balance of tokens in the contract
function balanceOf() public view returns (uint){
    return token.balanceOf(address(this)); 
}


//@notice: balance of tokens of an owner 
function MisTokens() public view returns (uint){
    return token.balanceOf(msg.sender);
}

//@notice: returns tokens
//@params: _numTokens is the amount of tokens the owner wants to return
function DevolverTokens(uint _numTokens) public payable {
    require(_numTokens > 0, "Necesitas devolver una cantidad positiva de tokens");
    require (_numTokens <= MisTokens(), "No tienes los tokens que deseas devolver");
    token.transferencia_Evento(msg.sender, address(this), _numTokens);
    payable(msg.sender).transfer(PrecioTokens(_numTokens));

}






//================================== FOOD MANAGEMENT =========================================



event nueva_comida(string, uint, bool);
event baja_comida(string);
event disfruta_comida(string, uint, address);


struct comida{
    string nombre_comida;
    string categoria;
    uint precio_comida;
    bool estado_comida;
}


mapping(string => comida) public MappingComida;

mapping (address => string[]) HistorialComida;

string [] Comidas;





//@notice: set a new meal
//@params: _nombreComida it's the name of the new meal
//         _categoria it's the category of the meal (dessert, beberage, starter, etc)
//         _precio it's the price of the meal in tokens
function NuevaComida(string memory _nombreComida, string memory _categoria, uint _precio) public Unicamente(msg.sender){
    MappingComida[_nombreComida] = comida(_nombreComida, _categoria, _precio, true);
    Comidas.push(_nombreComida);
    emit nueva_comida(_nombreComida, _precio, true);
}


//@notice: block a meal
//@params: _nombreComida it's the name of the meal you want to block
function BajaComida (string memory _nombreComida) public Unicamente(msg.sender){
    MappingComida[_nombreComida].estado_comida = false;
    emit baja_comida(_nombreComida);
}

//@notice: available meals
function ComidasDisponibles() public view returns(string[] memory){
    return Comidas;
}


//@notice: buy meal
//@params: _nombreComida it's the name of the meal you want to buy
function ComprarComida (string memory _nombreComida) public{
    uint tokens_comida = MappingComida[_nombreComida].precio_comida;
    require(MappingComida[_nombreComida].estado_comida == true, "Comida no disponible");
    require (tokens_comida <= MisTokens(), "Necesitas mas Tokens para comprar esta comida");

    token.transferencia_Evento(msg.sender, address(this), tokens_comida);
    HistorialComida[msg.sender].push(_nombreComida);

    emit disfruta_comida(_nombreComida, tokens_comida, msg.sender);
}



//@notice: consumer record
function HistorialComido() public view returns(string[] memory){
    return HistorialComida[msg.sender];
}


}