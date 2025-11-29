import express from "express";
import { MongoClient } from "mongodb"
import cors from "cors";
import { env } from "cloudflare:workers";
import { httpServerHandler } from "cloudflare:node";

const app = express();
const port = 3000;
const scoresDb = "leaderboards";
const scoresCollection = "scores";

app.use(express.json());
app.use(cors());

function mongoCollection(database, collection) {
  const mongoClient = new MongoClient(env.MONGO_DB);
  const db = mongoClient.db(database);
  return db.collection(collection);
}

async function getScores() {
  const collection = mongoCollection(scoresDb, scoresCollection);
  console.log("collection");
  const scores = await collection.find({}, { projection: { _id: 0 }}).sort({"time": -1}).toArray();
  console.log("got scores");
  return scores;
}

function cleanName(name) {
  name = name.replace(/[^A-Za-z0-9 _-]/g, "");
  name = name.substring(0, 16);
  if (name == "") {
    name = "anonymous";
  }
  return name;
}

function cleanScore(score) {
  score = parseInt(score);
  if (isNaN(score)) {
    score = 0;
  }
  return score;
}

async function postScore(data) {

  const collection = mongoCollection(scoresDb, scoresCollection);

  const name = cleanName(data.name);
  const score = cleanScore(data.score);
  const time = new Date();

  await collection.updateOne({ name }, { $set: { name, score, time }}, { upsert: true });
}

app.get('/', async (req, res) => {
  res.send("Ok");
})

app.get('/test', async (req, res) => {
  console.log(req.socket.remoteAddress)
  res.send();
})

app.post('/test', async (req, res) => {
  console.log(req.body)
  res.send();
})

app.post('/post_score', async (req, res) => {
  const data = req.body;
  await postScore(data);
  res.send();
})

app.get('/get_scores', async (req, res) => {
  const scores = await getScores();
  res.send(JSON.stringify(scores));
})

app.listen(port, () => {
  console.log(`Listening on port ${port}`);
})

export default httpServerHandler({ port });
