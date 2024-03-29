class DashboardController < ApplicationController

  def index
    a = capacidadAlmacen($almacen1id)
  end


  def almacen1
    @disponibleAlmacen1 = capacidadAlmacen($almacen1id) - espacio_ocupado_almacen($almacen1id)
    @ocupadoAlmacen1= espacio_ocupado_almacen($almacen1id)
  end

  def almacen2
    @disponibleAlmacen2 = capacidadAlmacen($almacen2id) - espacio_ocupado_almacen($almacen2id)
    @ocupadoAlmacen2 = espacio_ocupado_almacen($almacen2id)
  end

  def recepcion
    @disponibleRecepcion = capacidadAlmacen($recepcionid) - espacio_ocupado_almacen($recepcionid)
    @ocupadoRecepcion = espacio_ocupado_almacen($recepcionid)
  end

  def despacho
    @disponibleDespacho = capacidadAlmacen($despachoid) - espacio_ocupado_almacen($despachoid)
    @ocupadoDespacho = espacio_ocupado_almacen($despachoid)
  end

  def pulmon
    @disponiblePulmon = capacidadAlmacen($pulmonid) - espacio_ocupado_almacen($pulmonid)
    @ocupadoPulmon = espacio_ocupado_almacen($pulmonid)
  end

  def bodega
    capacidad = capacidadAlmacen($despachoid)+capacidadAlmacen($recepcionid)+capacidadAlmacen($almacen1id)+capacidadAlmacen($almacen2id)  #- espacio_ocupado_almacen($despachoid)
    ocupado = espacio_ocupado_almacen($almacen1id)+espacio_ocupado_almacen($almacen2id) + espacio_ocupado_almacen($recepcionid)+espacio_ocupado_almacen($despachoid)
    @disponibleBodega = capacidad-ocupado
    @ocupadoBodega = ocupado
  end

  def productos
    @huevo = consultar_stock_total('2')
    @cerealDeAvena = consultar_stock_total('12')
    @algodon = consultar_stock_total('21')
    @telaDeLino = consultar_stock_total('28')
    @cuero = consultar_stock_total('32')
  end

  def materiasprimas
    @avena = consultar_stock_total('15')
    @cacao = consultar_stock_total('20')
    @azucar = consultar_stock_total('25')
    @lino =  consultar_stock_total('37')
  end

  def trx
    @dia = params[:dia]
    @mes = params[:mes]
    @año = params[:año]
    @fecha = @dia+" - "+@mes+" - "+@año
    @numeroTrx = numeroTrxDia(@dia.to_i,@mes.to_i,@año.to_i)
    @transacciones = cartolaTrxDia(@dia.to_i,@mes.to_i,@año.to_i)
  end

  def ventas
    date7 = Time.now.to_i
    @dia7= numeroTrxDia2(date7*1000)
    date6= date7-86400
    @dia6= numeroTrxDia2(date6*1000)
    date5= date6-86400
    @dia5= numeroTrxDia2(date5*1000)
    date4= date5-86400
    @dia4= numeroTrxDia2(date4*1000)
    date3= date4-86400
    @dia3= numeroTrxDia2(date3*1000)
    date2= date3-86400
    @dia2= numeroTrxDia2(date2*1000)
    date1= date2-86400
    @dia1= numeroTrxDia2(date1*1000)
  end

  def saldobanco

    url = 'http://mare.ing.puc.cl/banco/cuenta/'+ '571262c3a980ba030058ab5c'
    result = HTTParty.get(url,
              headers: {
                'Content-Type' => 'application/json'
              })
    json = JSON.parse(result.body)
    plata = json[0]['saldo'].to_s
    @saldo = "$"+plata


  end


  #----------------Otros-----------------

  def numeroTrxDia(dia, mes, año)
    url = 'http://mare.ing.puc.cl/banco/cartola'

    ayer1 = Date.new(año,mes,dia).to_time.to_i
    ayer2= ayer1.to_s+"000"
    hoy1 = ayer1 + 86400
    hoy2 = hoy1.to_s+"000"


    result = HTTParty.post(url,
                    body:    {
                      fechaInicio:ayer2,
                      fechaFin:hoy2,
                      id: $bancoid,

                    }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
    json = JSON.parse(result.body)
    cantidadTrx = json['total']
    return cantidadTrx
  end

  def numeroTrxDia2(timestamp)
    url = getLinkServidorCurso()+'banco/cartola'
    ayer = timestamp-86400000
    result = HTTParty.post(url,
                    body:    {
                      fechaInicio:ayer,
                      fechaFin:timestamp,
                      id: $bancoid,

                    }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
    json = JSON.parse(result.body)
    cantidadTrx = json['total']
    return cantidadTrx
  end


  def cartolaTrxDia(dia, mes, año)
    url = getLinkServidorCurso() +'banco/cartola'
    ayer1 = Date.new(año,mes,dia).to_time.to_i
    ayer2= ayer1.to_s+"000"
    hoy1 = ayer1 + 86400
    hoy2 = hoy1.to_s+"000"

    result = HTTParty.post(url,
                    body:    {
                      fechaInicio:ayer2,
                      fechaFin:hoy2,
                      id: $bancoid,

                    }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
    json = JSON.parse(result.body)
    cartola = json['data']
    return cartola
  end

end
