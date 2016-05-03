class Api::FacturasController < ApplicationController
  skip_before_action :verify_authenticity_token

  def recibir
    idFactura = params[:idfactura]
    factura = obtener_factura(idFactura)
    if validar_factura(idFactura, factura) # Comparando con nuestra base de datos
      if pagar_factura(idFactura)
        # TODO: Falta implementar
       	#transferencia = transferir(factura)[0] #TODO: Manejar cuando la transferencia retorna error.
       	#enviarTransferencia(transferencia)
        render json: factura
      else
        render json: {"error": "No se pudo pagar la factura"}, status: 503 and return
      end
    else
      # Ya se hizo el rendering en validar_factura
      # No hacer nada...
    end
  end

  private

  def pagar_factura(factura)
    require 'httparty'
  	montoFactura = factura['monto']
    idCuentaOrigen = getIdBanco('2')
    grupoVendedor = factura['proveedor']
    idCuentaDestino = getIdBanco(grupoVendedor)

    begin
      puts "--------Pagando Factura--------------"
      url = "http://mare.ing.puc.cl/banco/trx/"
      result = HTTParty.put(url,
              body: {
                monto: montoFactura,
                origen: idCuentaOrigen,
                destino: idCuentaDestino,
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      puts "--------Factura Pagada--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def enviarTransferencia(transaccion, grupoDestinatario)
  	idTransaccion = transaccion['_id'].to_s
  	url = grupoDestinatario + 'api/pagos/recibir/' + idTransaccion
    puts "--------Enviando Transferencia--------------"
    result = HTTParty.post(url,
            body: transaccion,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = JSON.parse(result.body)
    puts "--------Transferencia Enviada--------------"
    return json
  end

  def marcar_factura_pagada(idFactura)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Marcando Factura Pagada--------------"
      url = "http://mare.ing.puc.cl/facturas/"
      result = HTTParty.post(url+"pay",
              body: {
                id: idFactura,
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      #TODO: Actualizar OC local
      puts "--------Factura Marcada Pagada--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def validar_factura(idFactura, factura)
    oc = Oc.find_by idoc: factura['oc']
    if factura == nil
      puts "--------Factura NO Existe---------"
      render json: {"error": "Factura Rechazada, no existe en el sistema del curso"}, status: 400 and return false # 400 = Bad Request, error del cliente
    elsif factura['proveedor'].to_s != $groupid
      puts "--------Factura RECHAZADA---------! No soy el proveedor de la factura"
      render json: {"error": "Factura Rechazada, no soy el proveedor de la factura"}, status: 400 and return false # 400 = Bad Request, error del cliente
    elsif oc == nil
      puts "--------Factura RECHAZADA---------! No tengo la Oc en mi base de datos (Mi empresa no la generó)"
      render json: {"error": "Factura Rechazada, no tengo la OC en mi base de datos (Mi empresa no la generó)"}, status: 400 and return false
    elsif oc['idfactura'].to_s != params[:idfactura].to_s
      puts "--------Factura RECHAZADA---------! La id de la factura no corresponde con la OC. oc.idfactura: " + oc['idfactura'].to_s + " --param: " + params[:idfactura]
      render json: {"error": "Factura Rechazada, la id de esta factura y la factura de la oc no coinciden"}, status: 400 and return false
    else
      puts "--------Factura Aceptada---------"
      return true
    end
  end

  def obtener_factura(idFactura)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo Factura--------------"
      url = "http://mare.ing.puc.cl/facturas/"
      result = HTTParty.get(url+idFactura,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      #TODO: Actualizar OC local
      puts "--------Factura Obtenida--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

end