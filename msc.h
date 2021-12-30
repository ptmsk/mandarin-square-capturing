#include <iostream>
#include <vector>
using namespace std;

enum Choice {
    SHOWRULES, 
    PLAYGAME, 
    PLAYGAMEWBOT,
    EXIT
};

enum State {
    CONT,
    P1WIN,
    P2WIN,
    DRAW
};

// Mandarin Square Capturing Game
class MSCGame {
private:
    class Player {
    public:
        int p;
        int m;
        int borrow;
        Player() : p(0), m(0), borrow(0) {}
    };
private:
    // setting
    const int peasantScore = 1;
    const int mandarinScore = 5;
    const int numOfBlocks = 12;
private:
    pair<Player, Player> players;
    vector<int> blocks;
    vector<int> AIboard;
    int m1, m2;
    /* BLOCKS: M as mandarin, P as peasant
        array (12 elements):
            M(left) - P(up) - P(up) - P(up) - P(up) - P(up) - M(right) - P(low) - P(low) - P(low) - P(low) - P(low)
            MAR-MIPS: 12 word blocks
        

        image:
        |---| P | P | P | P | P |---|
        | M |-------------------| M |
        |---| P | P | P | P | P |---|
    */
private:
    Choice menu(bool &);
    void displayRules();
    void displayBoard();
    void showResult(State state);
    int distribute(const int &, const int &);
    State player1Move();
    State player2Move();

    State computerMove();
    int preMove();
    void copy();
    void playGameWBot();
    int bot_distribute(const int &, const int &);

    bool endGameChecker(vector<int> &board);
    void scattering(const bool &, vector <int> &);
    void playGame();
    void showScore();
public:
    MSCGame();
    ~MSCGame();
    void run();
};

MSCGame::MSCGame() {
    // INITIALIZE blocks with 12 elements
    // first and 7th element are mandarin: initialize with score 5 (as 1 mandarin in each block, mandarin scores 5)
    // the rest are peasants: initialize also with score 5 (as 5 peasants in each block, peasant scores 1)
    // m1, m2 are the status of 2 mandrains, where 0 is on the table, 1 is in player1 pocket and 2 is in players pocket
    for(int i = 0; i < 12; i++){
        this -> blocks.push_back(5);
    }
    for(int i = 0; i < 12; i++){
        this -> AIboard.push_back(5);
    }
    m1 = 0;
    m2 = 0;
}

MSCGame::~MSCGame(){
    cout << "Thanks for playing~~";
}

void MSCGame::run() {
    Choice choice;
    bool played = false;
    while (true) {
        choice = this->menu(played);
        if (choice == EXIT)
            break;
        
        if (choice == SHOWRULES) {
            this->displayRules();
            continue;
        }
        
        if (choice == PLAYGAME){
            this->playGame();
            played = true;
        }

        if(choice == PLAYGAMEWBOT){
            this -> playGameWBot();
            played = true;
        }
    }
}

Choice MSCGame::menu(bool &played) {
    // TO DO: DISPLAY MENU ON CONSOLE
    // GET CHOICE
    // RETURN CHOICE 
    int inp = 0;
    if(!played){
        cout << "***Welcome to MSC for 2 players***\n";
    }
    else{
        cout << "***Game over***\n";
    }
    cout << "MENU:\n"
            << "0: Show Rules\n"
            << "1: Play Game with player\n"
            << "2: Play Game with Computer\n"
            << "3: Quit game\n";
    
    cin >> inp;
    if(inp > 3){
        throw ("Invalid");
    }
    else if(inp == 0){
        return SHOWRULES;
    }
    else if(inp == 1){
        return PLAYGAME;
    }
    else if(inp == 2){
        return PLAYGAMEWBOT;
    }
    else{
        return EXIT;
    }
}

void MSCGame::displayRules(){
    cout << "some rule will be list here\n";
}

void MSCGame::displayBoard() {
    // DISPLAY BOARD ON CONSOLE
    /*
    |---| P | P | P | P | P |---|
    | M |-------------------| M |
    |---| P | P | P | P | P |---|
    */
    cout << "\n************************************\n";
    cout << "|----|";
    for(int i = 1; i < 6; i++){
        if(this -> blocks[i] < 10){
            cout << ' ' << "0" << this -> blocks[i] << " |";
        }
        else{
            cout << ' ' << this -> blocks[i] << " |";
        }
    }
    cout <<"----|\n";
    if(this -> blocks[0] < 10){
        cout << "| " << "0" << this -> blocks[0];
    }
    else{
        cout << "| " << this -> blocks[0];
    }
    cout << " |------------------------| ";
    if(this -> blocks[6] < 10){
        cout << "0" << this -> blocks[6];
    }
    else{
        cout << this -> blocks[6];
    }
    cout << " |\n";
    cout << "|----|";
    for(int i = 11; i > 6; i--){
        if(this -> blocks[i] < 10){
            cout << ' ' << "0" << this -> blocks[i] << " |";
        }
        else{
            cout << ' ' << this -> blocks[i] << " |";
        }
    }
    cout <<"----|\n";
    cout << "************************************\n\n";
}

void MSCGame::showScore(){
    cout << "Score:\n";
    int score1 = this -> players.first.p + this -> players.first.m*5;
    int score2 = this -> players.second.p + this -> players.second.m*5;
    cout << "Player 1: " << "peasants: " << this -> players.first.p << " and mandrain: " << this -> players.first.m << " total: " << score1 << endl;
    cout << "Player 2: " << "peasants: " << this -> players.second.p << " and mandrain: " << this -> players.second.m << " total: "<< score2 << endl;
}

int MSCGame::distribute(const int& b, const int &d){
    //Distribute peasants from chosen block, return the next of the last block index
    int idx = b;
    int move = this -> blocks[b];
    this -> blocks[b] = 0;
    for (int i = 0; i < move; i++){
        idx+=d;
        if(idx > 11) idx = 0;
        if(idx <0) idx = 11;
        this -> blocks[idx]++;
    }
    idx += d;
    if(idx > 11) idx = 0;
    if(idx <0) idx = 11;
    return idx;
}

int MSCGame::bot_distribute(const int& b, const int &d){
    //Distribute peasants from chosen block, return the next of the last block index
    int idx = b;
    int move = this -> AIboard[b];
    this -> AIboard[b] = 0;
    for (int i = 0; i < move; i++){
        idx+=d;
        if(idx > 11) idx = 0;
        if(idx <0) idx = 11;
        this -> AIboard[idx]++;
    }
    idx += d;
    if(idx > 11) idx = 0;
    if(idx <0) idx = 11;
    return idx;
}

void MSCGame::scattering(const bool &player, vector <int> &board){
    int idx;
    if(player){
        idx = 7;
    }
    else{
        idx = 0;
    }
    for (int i = idx; i < (idx + 5); i++){
        if(this -> AIboard[i] != 0) return; 
    }
    player ? cout << "Player 2 " : cout << "Player 1 ";
    cout << "out of peasants, scattering...\n";
    if(player == 0){
        if(this -> players.first.p < 5){
            cout << "Not enough peasants to scatter, borrowing your opponent ...\n";
            this -> players.second.p -= 5;
        }
        else{
            this -> players.first.p -= 5;
        }
    }
    else{
        if(this -> players.second.p < 5){
            cout << "Not enough peasants to scatter, borrowing your opponent ...\n";
            this -> players.first.p -= 5;
        }
        else{
            this -> players.second.p -= 5;
        }
    }
    for(int i = idx; i < (idx + 5); i++){
        this -> AIboard[i] = 1;
    }
    cout << "Scatter successfully\n";
    this -> displayBoard();
}

State MSCGame::player1Move() {
    // FOR PLAYER 1 TURN
    // CHOOSE blocks (CANNOT CHOOSE MANDARINS BLOCKS)
    // CHOOSE DIRECTION
    // RUN
    // CHECK BLOCK STATE
    // CHECK WHETHER GAME IS END
    // CHECK SCATTERING
    // RETURN STATE
    cout << "Player 1 to move, please choose a block to move from 1 to 5 (upper row)\n";
    int block;
    cin >> block;
    while(block > 5 || block < 1 || this -> blocks[block] == 0){
        cout << "Invalid block, please choose again\n";
        cin >> block;
    }
    cout << "Please choose a direction to distribute (-1 for left or 1 for right)\n";
    int direc;
    cin >> direc;
    if(direc != 1 && direc != -1){
        cout << "Invalid direction, please choose again\n";
        cin >> direc;
    }
    while(block != 0 && block != 6 && this -> blocks[block] != 0){
        block = this -> distribute(block, direc);
        this -> displayBoard();
    }
    while(this -> blocks[block] == 0){
        block += direc;
        if(block < 0){
            block = 11;
        }
        if(block > 11){
            block = 0;
        }
        if(this -> blocks[block] == 0){
            break;
        }
        else if(block == 0){
            if(this -> m1 == 0 && this -> blocks[0] < 10){
                break;
            }
            else if(this -> m1 == 0){
                this -> players.first.m += 1;
                this -> m1 = 1;
                this -> players.first.p += this -> blocks[0] - 5;
            }
            else if(this -> m1 != 0){
                this -> players.first.p += this -> blocks[0];
            }
            this -> blocks[0] = 0;
        }
        else if(block == 6){
            if(this -> m2 == 0 && this -> blocks[6] < 10){
                break;
            }
            else if(this -> m2 == 0){
                this -> players.first.m += 1;
                this -> m2 = 1;
                this -> players.first.p += this -> blocks[6] - 5;
            }
            else if(this -> m2 != 0){
                this -> players.first.p += this -> blocks[6];
            }
            this -> blocks[6] = 0;
        }
        else if(this -> blocks[block] != 0){
            this -> players.first.p += this -> blocks[block];
            this -> blocks[block] = 0;
        }
        block += direc;
        if(block < 0){
            block = 11;
        }
        if(block > 11){
            block = 0;
        }
        this -> displayBoard();
    }
    bool end = this -> endGameChecker(this -> blocks);   
    if(end){
        //Result if end
        //Calculate the score
        int score1 = this -> players.first.p + this -> players.first.m*5;
        int score2 = this -> players.second.p + this -> players.second.m*5;
        if(score1 > score2){
            return P1WIN;
        }
        else if(score1 < score2){
            return P2WIN;
        }
        else{
            return DRAW;
        }
    }
    else { 
        this -> scattering(false, this -> blocks);
        this -> scattering(true, this -> blocks);
        return CONT;
    }
}

State MSCGame::player2Move() {
    //FOR PLAYER 2 TURN
    // CHOOSE blocks (CANNOT CHOOSE MANDARINS BLOCKS)
    // CHOOSE DIRECTION
    // RUN
    // CHECK BLOCK STATE
    // CHECK WHETHER GAME IS END
    // CHECK SCATTERING
    // RETURN STATE
    cout << "Player 2 to move, please choose a block to move from 1 to 5 (lower row)\n";
    int block;
    cin >> block;
    while(block > 5 || block < 1 || this -> blocks[11 - block + 1] == 0){
        cout << "Invalid block, please choose again\n";
        cin >> block;
    }
    cout << "Please choose a direction to distribute (-1 for left or 1 for right)\n";
    int direc;
    cin >> direc;
    if(direc != 1 && direc != -1){
        cout << "Invalid direction, please choose again\n";
        cin >> direc;
    }
    direc = -direc;
    block = 11 - block + 1;
    while(block != 0 && block != 6 && this -> blocks[block] != 0){
        block = this -> distribute(block, direc);
        this -> displayBoard();
    }
    while(this -> blocks[block] == 0){
        block += direc;
        if(block < 0){
            block = 11;
        }
        if(block > 11){
            block = 0;
        }
        if(this -> blocks[block] == 0){
            break;
        }
        else if(block == 0){
            if(this -> m1 == 0 && this -> blocks[0] < 10){
                break;
            }
            else if(this -> m1 == 0){
                this -> players.second.m += 1;
                this -> m1 = 1;
                this -> players.second.p += this -> blocks[0] - 5;
            }
            else if(this -> m1 != 0){
                this -> players.second.p += this -> blocks[0];
            }
            this -> blocks[0] = 0;
        }
        else if(block == 6){
            if(this -> m2 == 0 && this -> blocks[6] < 10){
                break;
            }
            else if(this -> m2 == 0){
                this -> players.second.m += 1;
                this -> m2 = 1;
                this -> players.second.p += this -> blocks[6] - 5;
            }
            else if(this -> m2 != 0){
                this -> players.second.p += this -> blocks[6];
            }
            this -> blocks[6] = 0;
        }
        else if(this -> blocks[block] != 0){
            this -> players.second.p += this -> blocks[block];
            this -> blocks[block] = 0;
        }
        block += direc;
        if(block < 0){
            block = 11;
        }
        if(block > 11){
            block = 0;
        }
        this -> displayBoard();
    }
    bool end = this -> endGameChecker(this -> blocks);    
    if(end){
        //Result if end
        //Calculate the score
        int score1 = this -> players.first.p + this -> players.first.m*5;
        int score2 = this -> players.second.p + this -> players.second.m*5;
        if(score1 > score2){
            return P1WIN;
        }
        else if(score1 < score2){
            return P2WIN;
        }
        else{
            return DRAW;
        }
    }
    else {
        this -> scattering(false, this -> blocks);
        this -> scattering(true, this -> blocks);
        return CONT;
    }
}

State MSCGame::computerMove() {
    // FOR COMPUTER TURN
    // CHOOSE blocks (CANNOT CHOOSE MANDARINS BLOCKS)
    // PREDICT
    // CHOOSE DIRECTION
    // RUN
    // CHECK BLOCK STATE
    // CHECK WHETHER GAME IS END
    // CHECK SCATTERING
    // RETURN STATE
    cout << "Computer to move, please wait...\n";
    int res = this -> preMove();
    cerr << res << endl;
    int block;
    int direc;
    if(res % 2) direc = 1;
    else direc = -1;
    block = res/2 + 1;
    block = 11 - block + 1;
    this -> displayBoard();
    while(block != 0 && block != 6 && this -> blocks[block] != 0){
        block = this -> distribute(block, direc);
        this -> displayBoard();
    }
    while(this -> blocks[block] == 0){
        block += direc;
        if(block < 0){
            block = 11;
        }
        if(block > 11){
            block = 0;
        }
        if(this -> blocks[block] == 0){
            break;
        }
        else if(block == 0){
            if(this -> m1 == 0 && this -> blocks[0] < 10){
                break;
            }
            else if(this -> m1 == 0){
                this -> players.second.m += 1;
                this -> m1 = 1;
                this -> players.second.p += this -> blocks[0] - 5;
            }
            else if(this -> m1 != 0){
                this -> players.second.p += this -> blocks[0];
            }
            this -> blocks[0] = 0;
        }
        else if(block == 6){
            if(this -> m2 == 0 && this -> blocks[6] < 10){
                break;
            }
            else if(this -> m2 == 0){
                this -> players.second.m += 1;
                this -> m2 = 1;
                this -> players.second.p += this -> blocks[6] - 5;
            }
            else if(this -> m2 != 0){
                this -> players.second.p += this -> blocks[6];
            }
            this -> blocks[6] = 0;
        }
        else if(this -> blocks[block] != 0){
            this -> players.second.p += this -> blocks[block];
            this -> blocks[block] = 0;
        }
        block += direc;
        if(block < 0){
            block = 11;
        }
        if(block > 11){
            block = 0;
        }
        this -> displayBoard();
    }
    bool end = this -> endGameChecker(this -> blocks);    
    if(end){
        //Result if end
        //Calculate the score
        int score1 = this -> players.first.p + this -> players.first.m*5;
        int score2 = this -> players.second.p + this -> players.second.m*5;
        if(score1 > score2){
            return P1WIN;
        }
        else if(score1 < score2){
            return P2WIN;
        }
        else{
            return DRAW;
        }
    }
    else {
        this -> scattering(false, this -> blocks);
        this -> scattering(true, this -> blocks);
        return CONT;
    }
}

int MSCGame::preMove(){
    //reserse resources
    cerr << "Premoving ...\n";
    int currP = this -> players.second.p;
    int currM = this -> players.second.m;
    int currPoint = currP + currM*5;
    int maxPoint = currPoint;
    int res = 0;
    int direc, block;
    for(int i = 0; i < 10; i++){
        cerr << "Step " << i << endl;
        block = (11 - i/2);
        if (this -> blocks[block] == 0) continue;
        if(i % 2 == 0) direc = -1;
        else direc = 1;
        cerr << "check " << block << ' ' << direc << endl;
        this -> copy();
        //Move Function (copy)
        while(block != 0 && block != 6 && this -> AIboard[block] != 0){
            block = this -> bot_distribute(block, direc);
        }
        while(this -> AIboard[block] == 0){
            block += direc;
            if(block < 0){
                block = 11;
            }
            if(block > 11){
                block = 0;
            }
            if(this -> AIboard[block] == 0){
                break;
            }
            else if(block == 0){
                if(this -> m1 == 0 && this -> AIboard[0] < 10){
                    break;
                }
                else if(this -> m1 == 0){
                    this -> players.second.m += 1;
                    this -> m1 = 1;
                    this -> players.second.p += this -> AIboard[0] - 5;
                }
                else if(this -> m1 != 0){
                    this -> players.second.p += this -> AIboard[0];
                }
                this -> AIboard[0] = 0;
            }
            else if(block == 6){
                if(this -> m2 == 0 && this -> AIboard[6] < 10){
                    break;
                }
                else if(this -> m2 == 0){
                    this -> players.second.m += 1;
                    this -> m2 = 1;
                    this -> players.second.p += this -> AIboard[6] - 5;
                }
                else if(this -> m2 != 0){
                    this -> players.second.p += this -> AIboard[6];
                }
                this -> AIboard[6] = 0;
            }
            else if(this -> AIboard[block] != 0){
                this -> players.second.p += this -> AIboard[block];
                this -> AIboard[block] = 0;
            }
            block += direc;
            if(block < 0){
                block = 11;
            }
            if(block > 11){
                block = 0;
            }
        }
        // check result
        bool end = this -> endGameChecker(this -> AIboard);
        int newPoint;
        if(end){
            //Result if end
            //Calculate the score
            int score1 = this -> players.first.p + this -> players.first.m*5;
            int score2 = this -> players.second.p + this -> players.second.m*5;
            if(score1 > score2){
                //Player win
                newPoint = -100;
            }
            else if(score1 < score2){
                //Computer win
                newPoint = 100;
            }
            else{
                newPoint = 0;
            }
        }
        else {
            this -> scattering(true, this -> blocks);
            newPoint = this -> players.second.m*5 + this -> players.second.p;
        }
        if(maxPoint <= newPoint){
            res = i;
            maxPoint = newPoint;
        }
        this -> players.second.p = currP;
        this -> players.second.m = currM;
    }
    return res;
}

void MSCGame::copy(){
    for(int i = 0; i < 12; i++){
        this -> AIboard[i] = this -> blocks[i];
    }
}

bool MSCGame::endGameChecker(vector<int> &board){
    //To check whether the game is over
    //End when 2 blocks of mandrain out of token
    if(board[0] + board[6] == 0){
        //return peasants from the table to players
        for(int i = 1; i < 6; i++){
            this -> players.first.p += board[i];
        }
        for(int i = 7; i < 12; i++){
            this -> players.second.p += board[i];
        }
        //pay the loan
        if(this -> players.first.borrow != 0){
            this -> players.first.p -= this ->players.first.borrow;
            this -> players.second.p += this -> players.first.borrow;
            this -> players.first.borrow = 0;
        }
        if(this -> players.second.borrow != 0){
            this -> players.second.p -= this ->players.second.borrow;
            this -> players.first.p += this -> players.second.borrow;
            this -> players.second.borrow = 0;
        }
        return true;
    }
    else{
        return false;
    }
}

void MSCGame::showResult(State state) {
    // SHOW WHETHER PLAYER 1 or 2 WINS or DRAW
    cout << "No more peasant on the table, the game is over\n";
    cout << "*************************\n";
    int score1 = this -> players.first.p + this -> players.first.m*5;
    int score2 = this -> players.second.p + this -> players.second.m*5;
    cout << "***SCOREBOARD***\n";
    cout << "Player 1: " << score1 << endl;
    cout << "Player 2: " << score2 << endl;
    if(state == P1WIN){
        cout << "Player 1 win!\n";
    }
    else if (state == P2WIN){
        cout << "Player 2 win!\n";
    }
    else{
        cout << "DRAW!\n";
    }
    cout << "*************************\n";
}

void MSCGame::playGame() {
    State state = CONT; 
    cout << "Game Start!\n"; 
    this->displayBoard();
    this -> showScore();
    while (state == CONT) {
        state = this->player1Move();
        this -> showScore();
        if (state != CONT)
            break;
        state = this->player2Move();
        this -> showScore();
    }
    showResult(state);
}

void MSCGame::playGameWBot() {
    State state = CONT; 
    cout << "Game Start!\n"; 
    this->displayBoard();
    this -> showScore();
    while (state == CONT) {
        state = this->player1Move();
        this -> showScore();
        if (state != CONT)
            break;
        state = this->computerMove();
        this -> showScore();
    }
    showResult(state);
}

