{
 Este software foi escrito para auxiliar na importação de algumas informações
 das notas fiscais eletrônica (NFe), através do XML gerado.

 É possível selecionais mais de um XML e importálos todos de uma vez.

 O sistema importa o arquivo XML gerado e cria um dataset com as notas fiscais
 presentes no mesmo.

 Declaro que NÃO TEMOS VINCULO ALGUM com o SEBRAE, que desenvolve o emissor de
 NFe gratuito, ou qualquer outra entidade do governo.

 Este software e todos os seus fontes estão licenciados pelos termos da MIT.
 Um arquivo chamado LICENSING está presente na raíz do diretório, com os termos
 da licença.

 ###############################################################################
 Autor: DNatividade
 Data: 2021-10-10
 ###############################################################################
}
unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ActnList, DBGrids, ExtCtrls;

type

  { TfrmNFe }

  TfrmNFe = class(TForm)
    btXML: TBitBtn;
    DBGrid1: TDBGrid;
    DefineBufFields: TAction;
    ActionList1: TActionList;
    bfNFe: TBufDataset;
    dsNFe: TDataSource;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    procedure btXMLClick(Sender: TObject);
    procedure DefineBufFieldsExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmNFe: TfrmNFe;

implementation

uses   laz2_xmlread, laz2_dom;

{$R *.lfm}

{ TfrmNFe }

procedure TfrmNFe.btXMLClick(Sender: TObject);
var
  i: integer;
  doc: TXMLDocument;
  nEmissao, nNFE,
  nNItens, nNItens2: TDOMNode;
  filename: string;
  arq: TextFile;

begin
  if OpenDialog1.Execute then
    for i:=0 to OpenDialog1.Files.Count-1 do
    begin
      try
        //Read XML file from disk
        //filename:= OpenDialog1.FileName;
        filename:= OpenDialog1.Files[i];
        AssignFile(arq, filename);
        Reset(arq);
        ReadXMLFile(doc, arq);

        //configura o separador decimal para as conversoes de STRING para FLOAT
        DecimalSeparator:='.';

        bfNFe.Append;
        bfNFe.FieldByName('idNfe').AsInteger:= i+1;
        //////////////////////////////////////////////////////////////////////////
        //1 parte
        //////////////////////////////////////////////////////////////////////////
        nEmissao:= doc.DocumentElement.FindNode('NFe');
        while nEmissao <> nil do
        begin
          nNFE:= nEmissao.FirstChild;
          while nNFE <> nil do
          begin
            nNItens:= nNFE.FirstChild;
            while nNItens <> nil do
            begin
              if nNItens.NodeName = 'ide' then
              begin
                nNItens2:= nNItens.FirstChild;
                while nNItens2 <> nil do
                begin
                  if nNItens2.NodeName = 'serie' then
                    bfNFe.FieldByName('serie').AsInteger:= StrToInt(nNItens2.TextContent)
                  else if nNItens2.NodeName = 'nNF' then
                    bfNFe.FieldByName('nNF').AsInteger:= StrToInt(nNItens2.TextContent);

                  nNItens2:= nNItens2.NextSibling;
                end;
              end;
              nNItens:= nNItens.NextSibling;
            end;
            nNFE:= nNFE.NextSibling;
          end;
          nEmissao:= nEmissao.NextSibling;
        end;
        //////////////////////////////////////////////////////////////////////////
        //2 parte
        //////////////////////////////////////////////////////////////////////////
        nEmissao:= doc.DocumentElement.FindNode('protNFe');
        while nEmissao <> nil do
        begin
          nNFE:= nEmissao.FirstChild;
          while nNFE <> nil do
          begin
            nNItens:= nNFE.FirstChild;
            while nNItens <> nil do
            begin
              if nNItens.NodeName = 'tpAmb' then
                bfNFe.FieldByName('tpAmb').AsInteger:= StrToInt(nNItens.TextContent)
              else if nNItens.NodeName = 'verAplic' then
                bfNFe.FieldByName('verAplic').AsString:= nNItens.TextContent
              else if nNItens.NodeName = 'chNFe' then
                bfNFe.FieldByName('chNFe').AsString:= nNItens.TextContent
              else if nNItens.NodeName = 'dhRecbto' then
                bfNFe.FieldByName('dhRecbto').AsString:= nNItens.TextContent
              else if nNItens.NodeName = 'nProt' then
                bfNFe.FieldByName('nProt').AsString:= nNItens.TextContent
              else if nNItens.NodeName = 'digVal' then
                bfNFe.FieldByName('digVal').AsString:= nNItens.TextContent
              else if nNItens.NodeName = 'cStat' then
                bfNFe.FieldByName('cStat').AsString:= nNItens.TextContent
              else if nNItens.NodeName = 'xMotivo' then
                bfNFe.FieldByName('xMotivo').AsString:= nNItens.TextContent;

             nNItens:= nNItens.NextSibling;
            end;
            nNFE:= nNFE.NextSibling;
          end;
          nEmissao:= nEmissao.NextSibling;
        end;
        bfNFe.Post;
        //////////////////////////////////////////////////////////////////////////
      finally
        CloseFile(arq);
        doc.Free;
        DecimalSeparator:=',';
      end;
      btXML.Enabled:= false;
    end;
end;




procedure TfrmNFe.DefineBufFieldsExecute(Sender: TObject);
var i: integer;

begin
  Try
    //dados da nota fiscal
    bfNFe.FieldDefs.Add('idNfe', ftInteger); //ID da nota
    //
    bfNFe.FieldDefs.Add('serie', ftInteger); //serie da nfe. ex.: 1
    bfNFe.FieldDefs.Add('nNF', ftInteger); //numero da nfe
    //
    bfNFe.FieldDefs.Add('tpAmb', ftInteger); //tipo de ambiente. ex.: 1
    bfNFe.FieldDefs.Add('verAplic', ftString, 20); //versão da aplicaçãi. ex.: 14.4.31-AN1
    bfNFe.FieldDefs.Add('chNFe', ftString, 44); //chave de acesso da nfe
    bfNFe.FieldDefs.Add('dhRecbto', ftString, 25); //data/hora recebimento da nfe. ex.: 2021-10-04T08:47:51-03:00
    bfNFe.FieldDefs.Add('nProt', ftString, 25); //numero de protocolo
    bfNFe.FieldDefs.Add('digVal', ftString, 40); // ex.: hVTq9XkJKGJH+QUyfmAeSB3In9o= (base64)
    bfNFe.FieldDefs.Add('cStat', ftString, 5); //ex.: 100
    bfNFe.FieldDefs.Add('xMotivo', ftString, 60); //ex.: Autorizado o uso da NF-e
    bfNFe.CreateDataset;

    bfNFe.Open;
  finally

  end;

end;

procedure TfrmNFe.FormCreate(Sender: TObject);
begin
  DefineBufFields.Execute;
end;

end.

