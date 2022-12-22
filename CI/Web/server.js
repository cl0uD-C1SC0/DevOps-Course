let express = require('express');
let bodyParser = require('body-parser')
let app = express();
let http = require('http').Server(app);
let io = require('socket.io')(http);
let mongoose = require('mongoose');
require('dotenv').config();

app.use(express.static(__dirname));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}))

let Message = mongoose.model('Message',{
  name : String,
  message : String
})

var db_USER = process.env.DB_USER
var db_PASSWORD = process.env.DB_PASSWORD


let dbUrl = `mongodb+srv://${db_USER}:${db_PASSWORD}@simple-chat.qjtactg.mongodb.net/?retryWrites=true&w=majority`

app.get('/messages', (req, res) => {
  Message.find({},(err, messages)=> {
    res.send(messages);
  })
})

app.get('/messages/:user', (req, res) => {
  let user = req.params.user
  Message.find({name: user},(err, messages)=> {
    res.send(messages);
  })
})

app.post('/messages', async (req, res) => {
  try{
    let message = new Message(req.body);

    let savedMessage = await message.save()
      console.log('saved');

    let censored = await Message.findOne({message:'badword'});
      if(censored)
        await Message.remove({_id: censored.id})
      else
        io.emit('message', req.body);
      res.sendStatus(200);
  }
  catch (error){
    res.sendStatus(500);
    return console.log('error',error);
  }
  finally{
    console.log('Message Posted')
  }

})

io.on('connection', () =>{
  console.log('a user is connected')
})

mongoose.connect(dbUrl, (err) => {
  console.log('mongodb connected',err);
})

let server = http.listen(3000, () => {
  console.log('server is running on port', server.address().port);
});
