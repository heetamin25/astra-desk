const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
async function run(){
 const elements=new Map();
 const element=id=>{
  if(!elements.has(id))elements.set(id,{innerHTML:'',value:'',checked:false,querySelector:()=>null,append(){this.innerHTML='STREAMED_MESSAGE';}});
  return elements.get(id);
 };
 let resolveHistory,resolveChat,historyCalls=0,uuid=0;
 const ctx={window:{},sessionStorage:{getItem:()=>null,setItem:()=>{}},crypto:{randomUUID:()=>String(++uuid)},TextDecoder,
 document:{getElementById:element,querySelectorAll:()=>[],createElement:()=>({innerHTML:'',className:'',classList:{add(){}},querySelector:()=>({textContent:'',innerHTML:''}),append(){},setAttribute(){}})},
 fetch:async(url)=>{
  if(url==='/api/assistant/chat')return new Promise(resolve=>resolveChat=resolve);
  if(url.includes('history?')&&++historyCalls>1)return {ok:true,status:200,json:()=>new Promise(resolve=>resolveHistory=resolve)};
  return {ok:true,status:200,json:async()=>url.endsWith('/status')?{configured:true,model:'test',chunks:0}:url.endsWith('/sessions')?{items:[]}:url.endsWith('/metrics')?{requests_24h:0,errors_24h:0,tokens_24h:0,average_latency_ms:null}:{turns:[]}};
 }};
 vm.createContext(ctx);vm.runInContext(fs.readFileSync('frontend/coursework.js','utf8'),ctx);vm.runInContext(fs.readFileSync('frontend/assistant.js','utf8'),ctx);
 await ctx.window.renderAssistant(()=>{},()=>true);
 element('chat-new').onclick();
 await new Promise(setImmediate);
 element('chat-question').value='New question';
 const sending=element('chat-form').onsubmit({preventDefault(){}});
 assert.equal(element('chat-thread').innerHTML,'STREAMED_MESSAGE');
 resolveHistory({turns:[]});
 await new Promise(setImmediate);
 assert.equal(element('chat-thread').innerHTML,'STREAMED_MESSAGE','Delayed empty history must not erase a newly sent exchange');
 let delivered=false;
 resolveChat({ok:true,status:200,body:{getReader:()=>({read:async()=>delivered?{done:true}:(delivered=true,{done:false,value:new TextEncoder().encode('{"type":"done","latency_ms":1}\n')})})}});
 await sending;
 console.log('Chat history race: delayed history preserves the current exchange');
}
run().catch(e=>{console.error(e);process.exit(1);});
